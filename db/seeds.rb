# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Starting seed process..."
puts "🧹 Cleaning database..."

# Clear existing data in correct order to avoid foreign key constraints
CoachingSession.destroy_all
Availability.destroy_all
CoachProfile.destroy_all
User.destroy_all

puts "👤 Creating users..."

# Create coaches
coaches = []
5.times do |i|
  coach = User.create!(
    email: "coach#{i+1}@example.com",
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone,
    role: 'coach'
  )
  coaches << coach
  puts "  Created coach: #{coach.email}"
end

# Create students 
students = []
10.times do |i|
  student = User.create!(
    email: "student#{i+1}@example.com",
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone,
    role: 'student'
  )
  students << student
  puts "  Created student: #{student.email}"
end


puts "\n👨‍🏫 Creating coach profiles..."

# Created coach profiles after a coach was created above
coaches.each_with_index do |coach, index|
  puts "  Created profile for #{coach.name}"
end

puts "\n📅 Creating availabilities..."

# Helper method for the entire seeds file
def create_non_overlapping_availability(coach_profile, preferred_days_ahead = 3)
  max_attempts = 10
  attempt = 0

  while attempt < max_attempts
    # Try different days and times
    days_ahead = preferred_days_ahead + (attempt / 4)
    hour = 8 + (attempt % 4) * 3  # Try 8, 11, 14, 17

    start_time = days_ahead.days.from_now.change(hour: hour, min: 0, sec: 0)
    end_time = start_time + 2.hours

    # Check for overlaps
    overlapping = coach_profile.availabilities
                               .where("(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?)",
                                      start_time, start_time, end_time, end_time)
                               .exists?

    unless overlapping
      return Availability.create!(
        coach_profile: coach_profile,
        start_time: start_time,
        end_time: end_time,
        status: 'available'
      )
    end

    attempt += 1
  end

  # If we can't find a slot, raise an error
  raise "Could not find non-overlapping time slot for coach #{coach_profile.user.name}"
end

# Create availabilities for each coach
coaches.each do |coach|
  coach_profile = coach.coach_profile

  # Create past availabilities (for testing completed sessions)
  3.times do |day|
    start_time = (day + 1).days.ago.change(hour: [ 9, 11, 14, 16 ].sample)
    availability = Availability.create!(
      coach_profile: coach_profile,
      start_time: start_time,
      end_time: start_time + 2.hours,
      status: 'available'
    )
  end

  # Create future availabilities
  7.times do |day|
    # Morning slots
    morning_start = (day + 1).days.from_now.change(hour: 9)
    Availability.create!(
      coach_profile: coach_profile,
      start_time: morning_start,
      end_time: morning_start + 2.hours,
      status: 'available'
    )

    # Afternoon slots
    afternoon_start = (day + 1).days.from_now.change(hour: 14)
    Availability.create!(
      coach_profile: coach_profile,
      start_time: afternoon_start,
      end_time: afternoon_start + 2.hours,
      status: 'available'
    )
  end

  puts "  Created availabilities for #{coach.name}"
end

puts "\n🤝 Creating coaching sessions..."

# Create past completed sessions (with feedback)
coaches.each do |coach|
  2.times do
    past_availability = coach.coach_profile.availabilities
                             .where('start_time < ?', Time.current)
                             .where(status: 'available')
                             .sample

    if past_availability
      student = students.sample

      session = CoachingSession.create!(
        coach_profile: coach.coach_profile,
        student: student,
        availability: past_availability,
        status: "completed",
        satisfaction_score: [ 3, 4, 5 ].sample,
        notes: Faker::Lorem.paragraph(sentence_count: 3)
      )

      past_availability.update!(status: 'booked', student_id: student.id)

      puts "  Created completed session: #{coach.name} with #{student.name}"
    end
  end
end

# Create upcoming scheduled sessions
5.times do
  student = students.sample
  coach = coaches.sample

  future_availability = coach.coach_profile.availabilities
                             .where('start_time > ?', Time.current)
                             .where(status: 'available')
                             .sample

  if future_availability
    session = CoachingSession.create!(
      coach_profile: coach.coach_profile,
      student: student,
      availability: future_availability,
      status: 'scheduled'
    )

    future_availability.update!(status: 'booked', student_id: student.id)

    puts "  Created scheduled session: #{coach.name} with #{student.name}"
  end
end



# Create a cancelled session for testing
coach = coaches.first
student = students.first

availability = create_non_overlapping_availability(coach.coach_profile, 3)

cancelled_session = CoachingSession.create!(
  coach_profile: coach.coach_profile,
  student: student,
  availability: availability,
  status: 'cancelled'
)

puts "  Created cancelled session for testing"

# Create some sessions that need feedback (past scheduled sessions)
coaches.first(2).each do |coach|
  student = students.sample
  start_time = 1.day.ago.change(hour: 14)

  availability = Availability.create!(
    coach_profile: coach.coach_profile,
    start_time: start_time,
    end_time: start_time + 2.hours,
    status: 'booked',
    student: student
  )

  CoachingSession.create!(
    coach_profile: coach.coach_profile,
    student: student,
    availability: availability,
    status: 'scheduled'
  )

  puts "  Created session needing feedback for #{coach.name}"
end

puts "\n✅ Seed data created successfully!"
puts "\n📊 Summary:"
puts "  - #{User.where(role: UserRoles::COACH).count} coaches"
puts "  - #{User.where(role: UserRoles::STUDENT).count} students"
puts "  - #{CoachProfile.count} coach profiles"
puts "  - #{Availability.count} availabilities"
puts "  - #{CoachingSession.where(status: 'completed').count} completed sessions"
puts "  - #{CoachingSession.where(status: 'scheduled').count} scheduled sessions"
puts "  - #{CoachingSession.where(status: 'cancelled').count} cancelled sessions"


