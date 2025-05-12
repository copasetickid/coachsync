class CoachingSession < ApplicationRecord
  belongs_to :coach_profile
  belongs_to :student, class_name: "User"
  belongs_to :availability

  validates :status, inclusion: { in: %w[scheduled completed cancelled] }
  validates :coach_profile_id, presence: true
  validates :student_id, presence: true
  validates :availability_id, presence: true
  validates :satisfaction_score, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    allow_nil: true
  }

  # Scopes for filtering
  scope :scheduled, -> { where(status: "scheduled") }
  scope :completed, -> { where(status: "completed") }
  scope :cancelled, -> { where(status: "cancelled") }

  scope :upcoming, -> {
    joins(:availability)
      .where(status: 'scheduled')
      .where('availabilities.start_time > ?', Time.current)
      .order('availabilities.start_time ASC')
  }

  scope :past, -> {
    joins(:availability)
    .where("availabilities.end_time < ?", Time.current)
    .order('availabilities.end_time DESC')
  }

  def coach
    coach_profile.user
  end

  def start_time
    availability.start_time
  end

  def end_time
    availability.end_time
  end

  def student_name
    student.name
  end

  def mark_completed!(satisfaction_score: nil, notes: nil)
    update!(
      status: "completed",
      satisfaction_score: satisfaction_score,
      notes: notes
    )
  end

  def mark_cancelled!
    update!(status: "cancelled")
  end
end
