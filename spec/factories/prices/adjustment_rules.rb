FactoryBot.define do
  factory :prices_adjustment_rule, class: 'Prices::AdjustmentRule' do
    name { Faker::Lorem.word.capitalize }
    strategy_type { Prices::AdjustmentRule::STRATEGY_TYPES.sample }
    factor { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    time_frame { "daily" }
    threshold { Faker::Number.between(from: 0, to: 100) }
    competitor_rule { nil }
  end
end
