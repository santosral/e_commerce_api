FactoryBot.define do
  factory :order do
    user_id { 1 }
    total_price { "9.99" }
  end
end
