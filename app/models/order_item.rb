class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer, default: 1
  field :captured_price_id, type: BSON::ObjectId

  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
