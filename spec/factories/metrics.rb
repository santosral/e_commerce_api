FactoryBot.define do
  factory :metric do
    time_frame { "daily" }
    period { "2023-10-01" }
    metrics { { "add_to_cart_count" => 0, "order_count" => 0 } }
    association :product

    trait :weekly do
      time_frame { "weekly" }
      period { "2023-W43" }
    end

    trait :monthly do
      time_frame { "monthly" }
      period { "2023-10" }
    end

    trait :yearly do
      time_frame { "yearly" }
      period { "2023" }
    end
  end
end
