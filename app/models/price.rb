class Price
  include Mongoid::Document
  include Mongoid::Timestamps

  PRICING_STRATEGIES  = [ "cart_demand", "order_demand", "inventory", "competitor" ].freeze

  field :pricing_strategy, type: String
  field :adjustment_rule_time_frame, type: String
  field :amount, type: BigDecimal
  field :effective_date, type: DateTime, default: Time.zone.now

  index({ effective_date: 1 })

  embedded_in :item, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0, only_integer: false }
  validates :pricing_strategy, inclusion: { in: PRICING_STRATEGIES, message: "%{value} is not a valid pricing strategy" }
end
