class Price
  include Mongoid::Document

  CREATED_FROM = [ "demand", "inventory", "competitor" ]

  field :amount, type: Float
  field :effective_date, type: DateTime
  field :created_from, type: String

  belongs_to :product

  validates :amount, presence: true
  validates :effective_date, presence: true
  validates :created_from, inclusion: { in: CREATED_FROM, message: "%{value} is not a valid created_from value" }
end
