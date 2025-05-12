FactoryBot.define do
  factory :availability do
     status { "available" }
     start_time { DateTime.now + 1.day }
     end_time { DateTime.now + 1.day + 2.hours }

     trait :booked do
       status { "booked" }
     end

     trait :past do
       start_time { 3.hours.ago }
       end_time { 1.hour.ago }
     end
  end
end
