FactoryBot.define do
  factory :price do
    pricing_strategy { Price::PRICING_STRATEGIES.sample }
    amount { Faker::Commerce.price(range: 0..100.0) }
    effective_date { Time.zone.now }

    trait :with_demand_strategy do
      pricing_strategy { "demand" }
    end

    trait :with_inventory_strategy do
      pricing_strategy { "inventory" }
    end

    trait :with_competitor_strategy do
      pricing_strategy { "competitor" }
    end
  end
end
