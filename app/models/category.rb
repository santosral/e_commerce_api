class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :products

  validates :name, presence: { message: "Invalid category name" }
end
