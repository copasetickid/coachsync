FactoryBot.define do
  factory :coaching_session do
    association :coach_profile
    association :student, factory: [ :user, :student ]
    association :availability, factory: [ :availability, :booked ]
    status { 'scheduled' }
    satisfaction_score { nil }
    notes { nil }

    trait :completed do
      status { 'completed' }
      satisfaction_score { rand(1..5) }
      notes { Faker::Lorem.paragraph }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
