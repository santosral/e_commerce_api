class Price
  include Mongoid::Document
  include Mongoid::Timestamps

  PRICING_STRATEGIES  = [ "demand", "inventory", "competitor" ].freeze

  field :pricing_strategy, type: String
  field :amount, type: BigDecimal
  field :effective_date, type: DateTime, default: nil

  index({ effective_date: 1 })

  embedded_in :item, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0, only_integer: false }
  validates :pricing_strategy, inclusion: { in: PRICING_STRATEGIES, message: "%{value} is not a valid pricing strategy" }
end
