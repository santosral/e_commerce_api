class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :quantity, type: Integer, default: 0

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category
  has_many :order_items
  has_many :cart_items
  has_and_belongs_to_many :price_adjustment_rules, class_name: "Prices::AdjustmentRule"
  embeds_many :prices, as: :priced_item
  embeds_one :trend_tracker

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id, message: "must be unique within the category" }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  def current_price
    Price.current(prices: prices, current_time: Time.zone.now)
  end

  def adjust_price_by_demand(rule)
    debugger
    current_time = Time.zone.now
    price = current_price
    price.update(valid_until: current_time)
    price_percentage = price.amount * (rule.percentage / 100.0)
    new_price = prices.build(pricing_strategy: "demand", valid_from: current_time + 15.seconds)

    if rule.adjustment_type == "increase"
      new_price.amount = price.amount += price_percentage
    else
      new_price.amount = price.amount -= price_percentage
    end

    new_price.save
  end
end
