class TrendTracker
  include Mongoid::Document
  include Mongoid::Timestamps

  field :add_to_cart_count, type: Integer, default: 0
  field :order_count, type: Integer, default: 0

  embedded_in :product

  validates :add_to_cart_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :order_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def increment_add_to_cart
    self.add_to_cart_count += 1
    save
  end

  def apply_price_demand_rules
    rule = product.price_adjustment_rules.find_by(_type: "Prices::DemandRule")
    return if rule.blank?

    product.adjust_price(rule)
  end
end
