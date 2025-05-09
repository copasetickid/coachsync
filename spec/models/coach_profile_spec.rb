require 'rails_helper'

RSpec.describe CoachProfile, type: :model do
  let(:coach) { create(:user, :coach, name: Faker::Name.name) }
  let(:student) { create(:user, :student, name: Faker::Name.name) }

  describe "associations" do
    it "belongs to a user"  do
      profile = CoachProfile.new(user: coach)
      expect(profile.user).to eq coach
    end
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
      CoachProfile.create!(user: coach)
      dup_profile = CoachProfile.new(user: coach)
      expect(dup_profile).not_to be_valid
      expect(dup_profile.errors[:user_id]).to include "has already been taken"
    end
  end
end
