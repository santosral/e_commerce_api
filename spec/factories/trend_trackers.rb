FactoryBot.define do
  factory :trend_tracker do
    product { nil }
    add_to_cart_count { 1 }
    order_count { 1 }
  end
end
