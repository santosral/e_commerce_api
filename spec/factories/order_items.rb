FactoryBot.define do
  factory :order_item do
    quantity { 1 }
    captured_price_id { nil }

    association :order
    association :product
  end
end
