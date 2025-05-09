module UserRoles
  extend ActiveSupport::Concern

  COACH = "coach"
  STUDENT = "student"

  ROLES = [ COACH, STUDENT ].freeze

  def coach?
    role == COACH
  end
  def student?
    role == STUDENT
  end
end
