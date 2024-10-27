FactoryBot.define do
  factory :prices_adjustment_rule, class: 'Prices::AdjustmentRule' do
    name { 'High demand' }
    strategy_type { Prices::AdjustmentRule::STRATEGY_TYPES.sample }
    threshold { Faker::Number.between(from: 0, to: 10) }
    factor { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    time_frame { Metric::TIME_FRAMES.sample }

    trait :high_factor do
      factor { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    end

    trait :low_thresholds do
      threshold { 0 }
    end
  end
end
