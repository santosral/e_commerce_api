class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :default_price, type: BigDecimal, default: 0
  field :quantity, type: Integer, default: 0

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category, autosave: true
  has_many :prices

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id, message: "must be unique within the category" }
  validates :default_price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
