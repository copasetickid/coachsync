FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    timezone { "UTC" }
    role { UserRoles::STUDENT }

    factory :coach do
      role { UserRoles::COACH }
      phone { Faker::PhoneNumber.cell_phone }
    end

    factory :student do
      role { UserRoles::STUDENT }
    end
  end
end
