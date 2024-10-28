FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    base_price { Faker::Commerce.price(range: 1..100.0) }
    quantity { Faker::Number.between(from: 1, to: 100) }

    after(:build) do |product|
      product.category = create(:category)
    end

    trait :with_price_adjustments do
      transient do
        price_adjustments_count { 1 }
        amount { Faker::Commerce.price(range: 1..100.0) }
      end

      after(:create) do |product, evaluator|
        create_list(:price, evaluator.price_adjustments_count,
          amount: evaluator.amount, item: product)
      end
    end

    trait :with_demand_adjustments do
      transient do
        time_frame { 'daily' }
        period { "2023-10-01" }
        strategy_type { 'demand' }
        threshold { 100 }
        factor { 1.2 }
      end

      after(:create) do |product, evaluator|
        adjustment_rule = create(:prices_adjustment_rule, name: evaluator.name,
          strategy_type: evaluator.strategy_type, threshold: evaluator.threshold,
          order_threshold: evaluator.order_threshold, factor: evaluator.factor, time_frame: evaluator.time_frame)
        product.price_adjustment_rules << adjustment_rule
      end
    end
  end
end
