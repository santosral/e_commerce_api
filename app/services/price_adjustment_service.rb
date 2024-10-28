class PriceAdjustmentService
  Result = Struct.new(:success?, :message, :price_adjustment)

  def initialize(product, time_frame:, strategy_type:)
    @product = product
    @time_frame = time_frame
    @strategy_type = strategy_type
  end

  def call
    rule = @product.price_adjustment_rules.where(time_frame: @time_frame, strategy_type: @strategy_type).first
    if rule.blank?
      Rails.logger.info "No demand adjustment rule found for product #{@product.id}"
      return Result.new(false, "No demand adjustment rule found for product #{@product.id}")
    end

    trend = Trend.aggregate_by_timeframe(product: @product, time_frame: @time_frame)
    if trend[:total_cart_additions] == 0 && trend[:total_orders] == 0
      Rails.logger.info "#{@strategy_type} does not fulfill the rule"
      return Result.new(false, "#{@strategy_type} does not fulfill the rule")
    end

    date_range = TimeFrame.dates(@time_frame)

    price_adjustment = @product.price_adjustments
      .where(adjustment_rule_time_frame: @time_frame,
        pricing_strategy: @strategy_type,
        effective_date: date_range[:start_date]...date_range[:end_date])
      .first_or_initialize

    if price_adjustment.persisted?
      Rails.logger.info "Price #{rule.name} #{@strategy_type} already applied"
      return Result.new(false, "Price #{rule.name} #{@strategy_type} already applied")
    end

    calculated_amount = calculate_adjusted_price(rule, trend)
    if calculated_amount.nil?
      Rails.logger.info "Calculated price is null #{@product.id}"
      return Result.new(false, "Calculated price is null #{@product.id}")
    end

    price_adjustment.amount = calculated_amount
    @product.price_adjustments << price_adjustment

    if @product.save!
      Result.new(true, "Price adjustment applied successfully", price_adjustment)
    else
      Result.new(false, "Failed to save the product")
    end
  end

  private

    def calculate_adjusted_price(rule, trend)
      amount = @product.current_price.amount

      case @strategy_type
      when "cart_demand"
        return nil if rule.threshold > trend[:total_cart_additions]
      when "order_demand"
        return nil if rule.threshold > trend[:total_orders]
      when "inventory"
        return nil if rule.threshold < @product.quantity
      end

      amount * rule.factor
    end
end
