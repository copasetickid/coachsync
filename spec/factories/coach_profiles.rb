FactoryBot.define do
  factory :coach_profile do
    association :user, factory: user, role: UserRoles::COACH
    bio { "Very experienced at coaching"}

    trait :active_coach do
      active { true }
    end

    trait :inactive_coach do
      active { false }
    end
  end
end
