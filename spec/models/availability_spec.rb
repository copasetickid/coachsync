require 'rails_helper'

RSpec.describe Availability, type: :model do
  let(:coach) { create(:user, :coach, name: "Kendrick Lamar") }
  let(:coach_profile) { coach.coach_profile }

  describe "associations" do
    it "belongs to a coach" do
      availability_slot = create(:availability, coach_profile: coach_profile)

      expect(availability_slot.coach_profile).to eq coach_profile
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      availability_slot = coach_profile.availabilities.new(
        start_time: DateTime.now + 1.day,
        end_time: DateTime.now + 1.day +  2.hours,
        status: "available"
      )

      expect(availability_slot).to be_valid
    end

    it "is not valid without a coach profile" do
      availability_slot = build(:availability)
      expect(availability_slot).not_to be_valid
      expect(availability_slot.errors[:coach_profile_id]).to include "can't be blank"
    end

    it "requires the slot be exactly 2 hours" do
      availability_slot = coach_profile.availabilities.new(
        start_time: DateTime.now + 1.day,
        end_time: DateTime.now + 1.day + 1.hour,
        status: "available"
      )
      expect(availability_slot).not_to be_valid
      expect(availability_slot.errors[:base]).to include "Slot must be exactly 2 hours"
    end

    it "is valid with status 'available'" do
      availability_slot = Availability.new(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day,
        end_time: DateTime.now + 1.day + 2.hours,
        status: 'available'
      )
      expect(availability_slot).to be_valid
    end

    it "is valid with status 'booked'" do
      availability_slot = Availability.new(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day,
        end_time: DateTime.now + 1.day + 2.hours,
        status: 'booked'
      )
      expect(availability_slot).to be_valid
    end

    it "doesn't allow overlapping slots" do
      # Create a first availability from 10 AM to 12 PM
      Availability.create!(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day + 10.hours, # 10 AM
        end_time: DateTime.now + 1.day + 12.hours,   # 12 PM
        status: 'available'
      )

      # Completely overlapping (same time)
      availability_slot = Availability.new(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day + 10.hours, # 10 AM
        end_time: DateTime.now + 1.day + 12.hours,   # 12 PM
        status: 'available'
      )
      expect(availability_slot).not_to be_valid
      expect(availability_slot.errors[:base]).to include "This slot overlaps with an existing availability"
    end

    it "allows non-overlapping slots" do
      # Create a first availability from 10 AM to 12 PM
      Availability.create!(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day + 10.hours, # 10 AM
        end_time: DateTime.now + 1.day + 12.hours,   # 12 PM
        status: 'available'
      )

      # Before existing slot
      availability = Availability.new(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day + 7.hours,  # 7 AM
        end_time: DateTime.now + 1.day + 9.hours,    # 9 AM
        status: 'available'
      )
      expect(availability).to be_valid
    end

    it "allows overlapping slots for different coaches" do
      # Create another coach
      second_coach = create(:user, :coach, name: "Kelly Rowland")

      # Create a slot for first coach
      Availability.create!(
        coach_profile: coach_profile,
        start_time: DateTime.now + 1.day + 10.hours, # 10 AM
        end_time: DateTime.now + 1.day + 12.hours,   # 12 PM
        status: 'available'
      )

      # Same time for different coach should be valid
      availability = Availability.new(
        coach_profile: second_coach.coach_profile,
        start_time: DateTime.now + 1.day + 10.hours, # 10 AM
        end_time: DateTime.now + 1.day + 12.hours,   # 12 PM
        status: 'available'
      )
      expect(availability).to be_valid
    end


  end
end
