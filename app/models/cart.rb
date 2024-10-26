class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total_price, type: BigDecimal, default: 0.0

  has_many :cart_items

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
