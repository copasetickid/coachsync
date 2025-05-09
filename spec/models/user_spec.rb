require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user, :coach,
                    name:  Faker::Name.name,
                    timezone: "America/New_York")
      expect(user).to be_valid
    end

    it "is not valid without a name" do
      user = build(:user, :coach,
                   name: " ",
                   timezone: "America/New_York")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a phone number" do
      user = build(:user, :coach,
                   phone: "",
                   timezone: "America/New_York")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end


    it "is not valid without an email" do
      user = build(:user, :coach,
                   email: " ",
                   name: "John Doe",
                   timezone: "America/New_York")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is not valid without a valid timezone" do
      user = build(:user, :coach,
                    name: "John Doe",
                    email: "john@example.com",
                    timezone: "Saturn")
      expect(user).not_to be_valid
      expect(user.errors[:timezone]).to include("This is not a valid timezone")
    end

    it "is not valid with an invalid role" do
      user = User.new(
        name: "John Doe",
        email: "john@example.com",
        timezone: "America/New_York",
        role: "invalid_role"
      )
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("is not included in the list")
    end

    it "requires a unique email" do
      create(:user, :coach,
             name: "John Doe",
             phone: Faker::PhoneNumber.cell_phone,
             email: "john@example.com",
             timezone: "America/New_York"
      )

      user = User.new(
        name: "Jane Doe",
        email: "john@example.com", # Same email
        timezone: "America/New_York",
        role: UserRoles::STUDENT
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe "roles" do
    it "identifies a coach correctly" do
      coach = User.new(role: UserRoles::COACH)
      student = User.new(role: UserRoles::STUDENT)

      expect(coach.coach?).to be true
      expect(coach.student?).to be false
      expect(student.coach?).to be false
      expect(student.student?).to be true
    end
  end
end
