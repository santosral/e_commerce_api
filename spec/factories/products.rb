FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    default_price { Faker::Commerce.price }
    quantity { Faker::Number.between(from: 1, to: 100) }
    association :category
  end
end
