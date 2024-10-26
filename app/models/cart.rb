class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :cart_items

  def add_cart_item(cart_item_params)
    cart_item = cart_items.build(cart_item_params)

    Cart.transaction do
      if cart_item.valid?
        cart_item.save!
      else
        errors.add(:cart_item, cart_item.errors.messages)
        raise Mongoid::Errors::Validations.new(cart_item)
      end

      update_total_price
      Products::TrackCartAdditionsJob.perform_async(cart_item.product.id.to_s)
      Rails.logger.info "Added product #{cart_item.product.id} to cart #{id}"
    end

    cart_item
  rescue Mongoid::Errors::Validations
    Rails.logger.info "Validation errors: #{errors.messages}"

    false
  end

  def update_total_price
    if cart_items.present?
      self.total_price = cart_items.sum do |item|
        if item.captured_price_id.present?
          captured_price = item.product.price_adjustments.where(_id: item.captured_price_id).first
          amount = captured_price&.amount || 0.0
        else
          amount = item.product.current_price.amount
        end

        item.quantity * amount
      end
    else
      self.total_price = 0.0
    end

    save!
  end
end
