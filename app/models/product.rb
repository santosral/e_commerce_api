class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  PriceResult = Struct.new(:id, :amount)

  field :name, type: String
  field :base_price, type: BigDecimal
  field :quantity, type: Integer, default: 0

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category
  has_many :cart_items
  has_many :order_items
  has_many :metrics
  has_and_belongs_to_many :price_adjustment_rules, class_name: "Prices::AdjustmentRule"

  embeds_many :price_adjustments, class_name: "Price", as: :item

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id, message: "must be unique within the category" }
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :base_price_should_be_greater_than_zero
  validate :sufficient_quantity_available

  def current_price(price_id = nil)
    if price_id.present?
      price = price_adjustments.where(_id: price_id).first
      return PriceResult.new(id: price.id, amount: price.amount) if price.present?
    end

    current_time = DateTime.now.utc
    price = price_adjustments.where(effective_date: { "$lte" => current_time }).order_by(effective_date: -1).first
    return PriceResult.new(id: price.id, amount: price.amount) if price.present?

    PriceResult.new(id: nil, amount: base_price)
  end

  def can_apply_price_adjustment?(strategy_type)
    return false if price_adjustment_rules.empty?

    rule = price_adjustment_rules.where(strategy_type: strategy_type).first
    return false if rule.blank?

    period = current_period(rule.time_frame)
    price_adjustment = price_adjustments.where(adjustment_rule_period: period, strategy_type: strategy_type).first

    price_adjustment.blank?
  end

  def apply_price_adjustment_rules_by(strategy_type)
    return if price_adjustment_rules.empty?

    rule = price_adjustment_rules.where(strategy_type: strategy_type).first
    if rule.blank?
      Rails.logger.info "No demand adjustment rule found for product #{id}"
      return
    end

    period = current_period(rule.time_frame)
    return unless rule.can_apply_adjustment?(period)

    price_adjustment = price_adjustments.where(adjustment_rule_period: period, pricing_strategy: strategy_type).first_or_initialize
    return unless price_adjustment.new_record?

    metric = metrics.where(period: period).first
    return if metric.blank?

    calculated_amount = calculate_adjusted_price(strategy_type, rule, metric)
    return if calculated_amount.nil?

    price_adjustment.amount = calculated_amount
    price_adjustment.effective_date = Time.now.utc
    price_adjustments << price_adjustment

    save!
  end

  def reduce_quantity(quantity_to_deduct)
    self.quantity -= quantity_to_deduct
    save!
  end

  def increment_metrics(metric_type)
    Metric::TIME_FRAME_FORMATS.each do |time_frame, format|
      metric = metrics.find_or_initialize_by(time_frame: time_frame, period: current_period(time_frame))
      metric.increment_metric(metric_type)
      metric.save!
    end
  end

  private
    def base_price_should_be_greater_than_zero
      if BigDecimal(base_price) <= BigDecimal("0.00")
        errors.add(:base_price, "should be greater than 0.00")
      end
    end

    def sufficient_quantity_available
      if quantity < 0
        errors.add(:quantity, "cannot be negative")
      end
    end

    def current_period(time_frame)
      format = Metric::TIME_FRAME_FORMATS[time_frame].presence || nil
      return if format.nil?

      DateTime.now.utc.strftime(format)
    end

    def calculate_adjusted_price(strategy_type, rule, metric)
      amount = current_price.amount

      case strategy_type
      when "cart_demand"
        add_to_cart_count = metric.get_metric("add_to_cart_count")

        return nil if add_to_cart_count <= rule.threshold
      when "order_demand"
        order_count = metric.get_metric("order_count")

        return nil if order_count <= rule.threshold
      when "inventory"
        return nil if quantity >= rule.threshold
      end

      amount * rule.factor
    end
end
