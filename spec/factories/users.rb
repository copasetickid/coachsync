FactoryBot.define do
  factory :user do
    sequence :email do |n|
      generated = Faker::Internet.username
      "#{generated}-#{n}@example.com"
    end
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.cell_phone }
    timezone { "UTC" }

    trait :coach do
      role { UserRoles::COACH }
    end

    trait :student do
      role { UserRoles::STUDENT }
    end
  end
end
