class Price
  include Mongoid::Document
  include Mongoid::Timestamps

  PRICING_STRATEGIES  = [ "default", "demand", "inventory", "competitor" ].freeze

  field :pricing_strategy, type: String
  field :amount, type: BigDecimal
  field :valid_from, type: DateTime
  field :valid_until, type: DateTime

  index({ valid_from: 1 })
  index({ valid_until: 1 })

  embedded_in :priced_item, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0, only_integer: false }
  validates :valid_from, presence: true
  validates :valid_until, comparison: { greater_than: :valid_from }, allow_nil: true
  validates :pricing_strategy, inclusion: { in: PRICING_STRATEGIES, message: "%{value} is not a valid pricing strategy" }
  validate :no_overlapping_prices_with_current_price

  def self.current(prices:, current_time: Time.zone.now)
    valid_prices = prices.where(valid_from: { "$lte" => current_time })
    current_price = valid_prices.where(valid_until: { "$gte" => current_time }).order_by(valid_from: -1).first
    current_price ||= valid_prices.where(valid_until: nil).order_by(valid_from: -1).first
    current_price
  end

  def no_overlapping_prices_with_current_price
    return unless priced_item

    current_price = priced_item.current_price
    return unless current_price && current_price != self

    if current_price.valid_until.nil? || current_price.valid_until > valid_from
      errors.add(:base, "New price overlaps with the current price.")
    end
  end
end
