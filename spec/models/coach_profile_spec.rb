require 'rails_helper'

RSpec.describe CoachProfile, type: :model do
  let(:coach) { create(:user, :coach, name: Faker::Name.name) }
  let(:student) { create(:user, :student, name: Faker::Name.name) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:availabilities).dependent(:destroy) }
    it { should have_many(:coaching_sessions).dependent(:restrict_with_error) }
  end


  describe "validations" do

    it "is not valid without a user"  do
      profile = CoachProfile.new(active: true)
      expect(profile).not_to be_valid
      expect(profile.errors.messages).to have_key(:user)
    end

    it "requires a user to have a coach role"  do
      profile = CoachProfile.new(user: student)
      expect(profile).not_to be_valid
      expect(profile.errors[:user]).to include "User is not a coach"
    end

    it "validates uniqueness of user"  do
      dup_profile = CoachProfile.new(user: coach)
      expect(dup_profile).not_to be_valid
      expect(dup_profile.errors[:user_id]).to include "has already been taken"
    end
  end


  describe '#upcoming_sessions' do
    let(:coach_profile) { coach.coach_profile }
    let(:past_time) { 6.hours.ago }
    let(:future_time) { 2.hours.from_now }

    before do
      # Create past session
      past_availability = create(:availability,
                                 coach_profile: coach_profile,
                                 start_time: past_time,
                                 end_time: past_time + 2.hours)
      create(:coaching_session,
             coach_profile: coach_profile,
             availability: past_availability,
             student: student,
             status: 'scheduled'
      )

      # Create future sessions
      future_availability = create(:availability,
                                   coach_profile: coach_profile,
                                   start_time: future_time,
                                   end_time: future_time + 2.hour,
                                   status: "booked")

      @future_session = create(:coaching_session,
                               coach_profile: coach_profile,
                               student: student,
                               availability: future_availability,
                               status: "scheduled"
      )

      # Create completed session
      completed_availability = create(:availability,
                                      coach_profile: coach_profile,
                                      student: student,
                                      start_time: 1.day.ago,
                                      end_time: 1.day.ago + 2.hours,
                                      status: "booked")
      create(:coaching_session,
             coach_profile: coach_profile,
             availability: completed_availability,
             student: student,
             status: "completed")
    end

    it 'returns only scheduled future sessions' do
      expect(coach_profile.upcoming_sessions).to eq([@future_session])
    end
  end

  describe 'callbacks' do
    context 'when user is not a coach' do
      it 'fails validation' do
        coach_profile = build(:coach_profile, user: student)
        expect(coach_profile).not_to be_valid
        expect(coach_profile.errors[:user]).to include "User is not a coach"
      end
    end
  end
end


