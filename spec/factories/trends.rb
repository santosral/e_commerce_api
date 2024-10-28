FactoryBot.define do
  factory :trend do
    cart_additions_count { 0 }
    orders_count { 0 }
    recorded_at { Time.now }

    association :product

    trait :with_cart_additions do
      cart_additions_count { Faker::Number.between(from: 1, to: 100) }
    end

    trait :with_orders do
      orders_count { Faker::Number.between(from: 1, to: 100) }
    end

    trait :recent do
      recorded_at { Time.zone.now }
    end

    trait :older do
      recorded_at { 1.week.ago }
    end
  end
end
