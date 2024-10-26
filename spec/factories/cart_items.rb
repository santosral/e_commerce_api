FactoryBot.define do
  factory :cart_item do
    quantity { 1 }
    captured_price_id { nil }
    association :cart

    trait :with_product do
      transient do
        product_base_price { 100.00 }
      end

      after(:build) do |cart_item, evaluator|
        cart_item.product = create(:product, base_price: evaluator.product_base_price)
      end
    end

    trait :with_price_adjusted_product do
      transient do
        product_base_price { 100.00 }
        price_adjustment_amount { 120.00 }
      end

      after(:build) do |cart_item, evaluator|
        cart_item.product = create(:product, :with_price_adjustments, base_price: evaluator.product_base_price,
          amount: evaluator.price_adjustment_amount)
        cart_item.captured_price_id = cart_item.product.price_adjustments.first.id.to_s
      end
    end
  end
end
