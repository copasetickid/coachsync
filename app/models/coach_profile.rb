class CoachProfile < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :active, inclusion: { in: [ true, false ] }

  validate :user_is_a_coach

  private

  def user_is_a_coach
    if user && !user.coach?
      errors.add(:user, "User is not a coach")
    end
  end
end
