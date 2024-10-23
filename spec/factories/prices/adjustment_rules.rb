FactoryBot.define do
  factory :price_adjustment_rule, class: 'Prices::AdjustmentRule' do
    name { 'High demand' }
    strategy_type { Prices::AdjustmentRule::STRATEGY_TYPES.sample }
    add_to_cart_threshold { Faker::Number.between(from: 0, to: 10) }
    order_threshold { Faker::Number.between(from: 0, to: 10) }
    factor { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    time_frame { Metric::TIME_FRAMES.sample }
    last_adjusted_period { nil }
    last_adjusted_date { nil }

    trait :high_factor do
      factor { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    end

    trait :low_thresholds do
      add_to_cart_threshold { 0 }
      order_threshold { 0 }
    end
  end
end
