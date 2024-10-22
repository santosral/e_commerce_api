FactoryBot.define do
  factory :prices_adjustment_rule, class: 'Prices::AdjustmentRule' do
    adjustment_type { "MyString" }
  end
end
