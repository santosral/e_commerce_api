class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :order_items

  def self.create_from_cart(order_params)
    order = new

    Order.transaction do
      cart = Cart.find(order_params)
      cart_items = cart.cart_items

      if cart_items.empty?
        order.errors.add(:cart, "No Cart Items to process")
        Rails.logger.info "Invalid cart #{cart.id}: #{order.errors.messages}"
        raise Mongoid::Errors::Validations.new(cart)
      end

      cart.cart_items.each do |cart_item|
        order_item = OrderItem.new(
          order: order,
          product: cart_item.product,
          quantity: cart_item.quantity,
          captured_price_id: cart_item.captured_price_id,
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        )

        if order_item.valid?(:create_from_cart)
          order_item.save!

          product_id = order_item.product.id.to_s
          TrackTrendsJob.perform_async(product_id, "daily", "orders_count")

          order_item.product.reduce_quantity(order_item.quantity)
          PriceAdjustmentJob.perform_async(product_id, "daily", "inventory")
        else
          order.errors.add(:order_items, message: order_item.errors.full_messages.first)
          Rails.logger.info "Invalid order item for cart #{cart.id}: #{order.errors.messages}"
          raise Mongoid::Errors::Validations.new(order_item)
        end
      end

      order.update_total_price

      cart.cart_items.destroy_all
      cart.update_total_price
    end

    order
  rescue Mongoid::Errors::Validations
    Rails.logger.info "Validation errors: #{order.errors.messages}"

    order
  end

  def update_total_price
    if order_items.present?
      self.total_price = order_items.sum do |item|
        if item.captured_price_id.present?
          captured_price = item.product.price_adjustments.where(_id: item.captured_price_id).first
          amount = captured_price&.amount || 0.0
        else
          amount = item.product.base_price
        end

        price = amount
        item.quantity * price
      end
    else
      self.total_price = 0.0
    end

    save!
  end
end
