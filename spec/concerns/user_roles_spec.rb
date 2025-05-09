# spec/models/concerns/user_roles_spec.rb
require 'rails_helper'

RSpec.describe UserRoles do
  it "defines role constants" do
    expect(UserRoles::STUDENT).to eq('student')
    expect(UserRoles::COACH).to eq('coach')
  end

  it "defines a ROLES array" do
    expect(UserRoles::ROLES).to contain_exactly('student', 'coach')
  end

  describe "when included in a class" do
    let(:user_class) do
      Class.new do
        include UserRoles
        attr_accessor :role

        def initialize(role)
          @role = role
        end
      end
    end

    it "adds coach? method" do
      student_instance = user_class.new(UserRoles::STUDENT)
      coach_instance = user_class.new(UserRoles::COACH)

      expect(student_instance.coach?).to be false
      expect(coach_instance.coach?).to be true
    end

    it "adds student? method" do
      student_instance = user_class.new(UserRoles::STUDENT)
      coach_instance = user_class.new(UserRoles::COACH)

      expect(student_instance.student?).to be true
      expect(coach_instance.student?).to be false
    end
  end
end
