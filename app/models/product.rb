class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  PriceResult = Struct.new(:id, :amount)

  field :name, type: String
  field :base_price, type: BigDecimal
  field :quantity, type: Integer, default: 0

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category
  has_many :cart_items
  has_many :order_items
  has_many :trends
  has_and_belongs_to_many :price_adjustment_rules, class_name: "Prices::AdjustmentRule"

  embeds_many :price_adjustments, class_name: "Price", as: :item

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id, message: "must be unique within the category" }
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :base_price_should_be_greater_than_zero
  validate :sufficient_quantity_available

  def current_price(price_id = nil)
    if price_id.present?
      price = price_adjustments.where(_id: price_id).first
      return PriceResult.new(id: price.id, amount: price.amount) if price.present?
    end

    current_time = DateTime.now.utc
    price = price_adjustments.where(effective_date: { "$lte" => current_time }).order_by(effective_date: -1).first
    return PriceResult.new(id: price.id, amount: price.amount) if price.present?

    PriceResult.new(id: nil, amount: base_price)
  end

  def reduce_quantity(quantity_to_deduct)
    self.quantity -= quantity_to_deduct
    save!
  end

  private

    def base_price_should_be_greater_than_zero
      if BigDecimal(base_price) <= BigDecimal("0.00")
        errors.add(:base_price, "should be greater than 0.00")
      end
    end

    def sufficient_quantity_available
      if quantity < 0
        errors.add(:quantity, "cannot be negative")
      end
    end
end
