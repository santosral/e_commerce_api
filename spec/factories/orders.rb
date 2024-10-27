FactoryBot.define do
  factory :order do
    total_price { 0.0 }

    trait :with_order_items do
      transient do
        order_items_count { 1 }
      end

      after(:build) do |order, evaluator|
        order.order_items << build_list(:order_item, evaluator.order_items_count, order: order)
      end
    end
  end
end
