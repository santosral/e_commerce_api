FactoryBot.define do
  factory :cart do
    total_price { 0.0 }

    trait :with_cart_items do
      transient do
        cart_items_count { 1 }
        product_base_price { 100.00 }
      end

      after(:create) do |cart, evaluator|
        create_list(:cart_item, evaluator.cart_items_count, :with_product, cart: cart,
          product_base_price: evaluator.product_base_price)
      end
    end

    trait :with_price_adjusted_cart_items do
      transient do
        cart_items_count { 1 }
        product_base_price { 100.00 }
        price_adjustment_amount { 120.00 }
      end

      after(:create) do |cart, evaluator|
        create_list(:cart_item, evaluator.cart_items_count, :with_price_adjusted_product, cart: cart,
          product_base_price: evaluator.product_base_price, price_adjustment_amount: evaluator.price_adjustment_amount)
      end
    end
  end
end
