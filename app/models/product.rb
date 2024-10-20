class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :default_price, type: Float
  field :quantity, type: Integer

  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category, autosave: true
  has_many :prices

  validates :name, presence: true
  validate :unique_name_per_category

  def current_price
    prices.order_by(effective_date: :desc).first
  end

  private

  def unique_name_per_category
    if category.present? && Product.where(name: name, category_id: category.id).exists?
      errors.add(:name, "already exists in the selected category")
    end
  end
end
