class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :base_price, type: BigDecimal
  field :quantity, type: Integer, default: 0

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category
  has_many :order_items
  has_many :cart_items
  has_many :metrics
  has_and_belongs_to_many :price_adjustment_rules, class_name: "Prices::AdjustmentRule"

  embeds_many :price_adjustments, class_name: "Price", as: :item

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id, message: "must be unique within the category" }
  validates :base_price, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def current_price
    current_time = DateTime.now.utc
    price = price_adjustments.where(effective_date: { "$lte" => current_time }).order_by(effective_date: -1)
    return if price.blank?

    price.first
  end

  def increase_cart_metrics
    increment_metrics("add_to_cart_count")
  end

  def increase_order_metrics
    increment_metrics("add_to_cart_count")
  end

  def apply_price_adjustment_rules_by_demand
    return if price_adjustment_rules.empty?

    rule = price_adjustment_rules.where(strategy_type: "demand").first
    if rule.blank?
      Rails.logger.info "No demand adjustment rule found for product #{id}"
      return
    end

    period = current_period(rule.time_frame)
    return unless rule.can_apply_adjustment?(period)

    metric = metrics.find_by(period: period)
    return if metric.blank?

    amount = current_price&.amount || base_price
    add_to_cart_count = metric.get_metric("add_to_cart_count")
    calculated_amount = calculate_adjusted_price(amount, rule, add_to_cart_count)
    return if calculated_amount.nil?

    price = price_adjustments.build(
      amount: calculated_amount,
      pricing_strategy: "demand",
      effective_date: DateTime.now.utc
    )
    price_adjustments << price
    rule.last_adjusted_period(last_adjusted_period: period, last_adjusted_date: DateTime.now.utc)
    save!
  end

  def reduce_quantity(quantity_to_deduct)
    if quantity_to_deduct <= quantity
      self.quantity -= quantity_to_deduct
      save!
    else
      raise ArgumentError, "Cannot deduct more than available quantity"
    end
  end

  private
    def current_period(time_frame)
      format = Metric::TIME_FRAME_FORMATS[time_frame].presence || nil
      return if format.nil?

      DateTime.now.utc.strftime(format)
    end

    def calculate_adjusted_price(amount, rule, add_to_cart_count)
      return nil unless add_to_cart_count >= rule.add_to_cart_threshold

      amount * rule.factor
    end

    def increment_metrics(metric_type)
      Metric::TIME_FRAME_FORMATS.each do |time_frame, format|
        metric = metrics.find_or_initialize_by(time_frame: time_frame, period: current_period(time_frame))
        metric.increment_metric(metric_type)
        metric.save!
      end
    end
end
