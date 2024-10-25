class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :order_items

  def create_from_cart(cart)
    Order.transaction do
      cart_items = cart.cart_items

      if cart_items.empty?
        self.errors.add(:order_items, "No Cart Items to process")
        return false
      end

      cart.cart_items.each do |cart_item|
        order_item = OrderItem.new(
          order: self,
          product: cart_item.product,
          quantity: cart_item.quantity,
          captured_price_id: cart_item.captured_price_id,
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        )

        if order_item.valid?(:create_from_cart)
          order_items.build(order_item.attributes)

          order_item.save!
          order_item.product.reduce_quantity(order_item.quantity)
        else
          errors.add(:order_items, message: order_item.errors.full_messages.first)
          return false
        end
      end
      update_total_price
      save!

      cart.cart_items.destroy_all
      cart.update_total_price
    end
    true
  rescue Mongoid::Errors::Rollback
    false
  rescue Mongoid::Errors::Validations
    false
  end

  def update_total_price
    if order_items.present?
      self.total_price = order_items.sum do |item|
        if item.captured_price_id.present?
          captured_price = item.product.price_adjustments.find(item.captured_price_id)
          amount = captured_price.amount
        else
          amount = item.product.base_price
        end

        price = amount
        item.quantity * price
      end
    else
      self.total_price = 0.0
    end
  end
end
