class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :cart_items

  def update_total_price
    if cart_items.present?
      self.total_price = cart_items.sum do |item|
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

    save!
  end
end
