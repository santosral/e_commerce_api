class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer, default: 1
  field :captured_price_id, type: BSON::ObjectId

  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id, message: "has already been added to this cart" }

  after_create :increment_trend_tracker
  after_save :update_cart_total
  after_destroy :update_cart_total_after_destroy

  def price
    product.prices.find(captured_price_id) || product.current_price
  end

  private

  def update_cart_total
    cart.update_total_price
  end

  def update_cart_total_after_destroy
    cart.update_total_price(exclude: self)
  end

  def increment_trend_tracker
    product.trend_tracker.increment_add_to_cart
  end
end
