class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer, default: 1
  field :captured_price_id, type: BSON::ObjectId

  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id, message: "has already been added to this cart" }

  with_options on: :create do
    validate :captured_price_should_exist_in_product
    validate :quantity_must_not_exceed_product_stock
  end

  def add_to_cart
    Cart.transaction do
      save!
      cart.update_total_price
      Products::TrackCartAdditionsJob.perform_async(product.id.to_s)
    end
    true
  rescue Mongoid::Errors::Validations
    false
  end

  def remove_from_cart
    Cart.transaction do
      destroy!
      cart.update_total_price
    end
  end

  def update_cart(cart_item_params)
    Cart.transaction do
      self.assign_attributes(cart_item_params)
      if save!
        cart.update_total_price
      end
    end
    true
  rescue Mongoid::Errors::Validations
    false
  end

  private
    def captured_price_should_exist_in_product
      return false if product.current_price.blank?

      unless product.price_adjustments.exists?(captured_price_id)
        errors.add(:captured_price_id, :invalid_price, message: "Price does not exist")
      end
    end

    def quantity_must_not_exceed_product_stock
      if quantity > product.quantity
        errors.add(:quantity, "exceeds available stock")
      end
    end
end
