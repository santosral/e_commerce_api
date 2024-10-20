FactoryBot.define do
  factory :import_job, class: 'Products::ImportJob' do
    job_id { SecureRandom.uuid }
    status { "pending" }
    valid_rows { [] }
    invalid_rows { [] }

    trait :processing do
      status { "processing" }
    end

    trait :success do
      status { "success" }
    end

    trait :error do
      status { "error" }
    end
  end
end
