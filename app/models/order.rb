class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :order_items

  def update_total_price(exclude: nil)
    self.total_price = cart_items.where(id: { "$ne" => exclude&.id }).sum do |item|
      item.quantity * item.price
    end

    save
  end
end
