class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :captured_price, type: BigDecimal

  belongs_to :order
  belongs_to :product

  before_create :set_captured_price

  def set_captured_price
    self.captured_price = product.current_price.amount
  end

  def price
    Price.find(price_id)
  end
end
