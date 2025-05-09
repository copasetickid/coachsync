FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    timezone { "UTC" }

    trait :coach do
      role { UserRoles::COACH }
      phone { Faker::PhoneNumber.cell_phone }
    end

    trait :student do
      role { UserRoles::STUDENT }
      phone { Faker::PhoneNumber.cell_phone }
    end
  end
end
