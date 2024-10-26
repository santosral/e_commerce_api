class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer, default: 1
  field :captured_price_id, type: BSON::ObjectId

  index({ cart_id: 1 })
  index({ product_id: 1, cart_id: 1 }, unique: true)


  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true
  validates :quantity, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :product_id, uniqueness: { scope: :cart_id, message: "has already been added to this cart" }, on: :create

  with_options on: :create, if: -> { product.present? } do
    validate :captured_price_should_match_product_current_price
    validate :quantity_must_not_exceed_product_stock
  end

  def add_to_cart
    Cart.transaction do
      save!
      cart.update_total_price
      Products::TrackCartAdditionsJob.perform_async(product.id.to_s)
      Rails.logger.info "Added product #{product.id} to cart #{cart.id}"
    end

    true
  rescue Mongoid::Errors::Validations
    Rails.logger.info "Validation errors: #{errors.messages}"

    false
  end

  def remove_from_cart
    Cart.transaction do
      destroy!
      cart.update_total_price
      Rails.logger.info "Removed product #{product.id} from cart #{cart.id}"
    end

    true
  rescue StandardError => e
    Rails.logger.error "Failed to remove product #{product.id} from cart #{cart.id}: #{e.message}"

    false
  end

  def update_cart(cart_item_params)
    Cart.transaction do
      assign_attributes(cart_item_params)
      save!
      cart.update_total_price
      Rails.logger.info "Updated product #{product.id} in cart #{cart.id}."
    end

    true
  rescue Mongoid::Errors::Validations
    Rails.logger.info "Failed to update product #{product.id} in cart #{cart.id}: #{errors.messages}"

    false
  end

  private
    def captured_price_should_match_product_current_price
      if product.current_price.id != captured_price_id
        errors.add(:captured_price_id, :invalid_price, message: "Invalid price")
      end
    end

    def quantity_must_not_exceed_product_stock
      if quantity > product.quantity
        errors.add(:quantity, "exceeds available stock")
      end
    end
end
