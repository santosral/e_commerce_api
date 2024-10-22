FactoryBot.define do
  factory :prices_demand_rule, class: 'Prices::DemandRule' do
    adjustment_type { "increase" }
    add_to_cart_threshold { 1 }
    order_threshold { 1 }
    percentage { 50.0 }
  end
end
