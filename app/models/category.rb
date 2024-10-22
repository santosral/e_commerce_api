class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :products

  validates :name, presence: true
  validates :name, uniqueness: true
end
