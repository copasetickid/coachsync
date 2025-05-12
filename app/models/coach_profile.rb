class CoachProfile < ApplicationRecord
  belongs_to :user
  has_many :availabilities, dependent: :destroy
  has_many :coaching_sessions, dependent: :restrict_with_error

  validates :user_id, presence: true, uniqueness: true
  validates :active, inclusion: { in: [ true, false ] }

  validate :user_is_a_coach


  # Aggregation methods
  def average_satisfaction_score
    scores = coaching_sessions.completed.where.not(satisfaction_score: nil).pluck(:satisfaction_score)
    scores.any? ? scores.sum.to_f / scores.size : nil
  end

  def phone_number
    user.phone
  end

  def upcoming_sessions
    coaching_sessions
      .joins(:availability)
      .where(status: "scheduled")
      .where('availabilities.start_time > ?', Time.current)
      .where('availabilities.status = ?', 'booked')
      .order('availabilities.start_time ASC')
  end

  private

  def user_is_a_coach
    if user && !user.coach?
      errors.add(:user, "User is not a coach")
    end
  end
end
