class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer, default: 1
  field :captured_price_id, type: BSON::ObjectId

  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :quantity_must_not_exceed_product_stock, on: :create_from_cart

  private

  def quantity_must_not_exceed_product_stock
    if quantity > product.quantity
      errors.add(:quantity, "exceeds available stock")
    end
  end
end
