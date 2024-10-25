FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    base_price { Faker::Commerce.price(range: 1..100.0) }
    quantity { Faker::Number.between(from: 1, to: 100) }
    association :category

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

    trait :with_metrics do
      transient do
        metrics_count { 1 }
      end

      after(:create) do |product, evaluator|
        create_list(:metric, evaluator.metrics_count, product: product)
      end
    end

    trait :with_demand_adjustments do
      transient do
        time_frame { 'daily' }
        period { "2023-10-01" }
        metrics { { "add_to_cart_count" => 100, "order_count" => 100 } }
        strategy_type { 'demand' }
        add_to_cart_threshold { 100 }
        order_threshold { 100 }
        factor { 1.2 }
      end

      after(:create) do |product, evaluator|
        create(:metric, product: product, time_frame: evaluator.time_frame, metrics: evaluator.metrics,
          period: evaluator.period)

        adjustment_rule = create(:prices_adjustment_rule, name: evaluator.name,
          strategy_type: evaluator.strategy_type, add_to_cart_threshold: evaluator.add_to_cart_threshold,
          order_threshold: evaluator.order_threshold, factor: evaluator.factor, time_frame: evaluator.time_frame)
        product.price_adjustment_rules << adjustment_rule
      end
    end
  end
end
