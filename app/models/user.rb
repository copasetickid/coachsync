class User < ApplicationRecord
  include UserRoles

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true
  validates :phone, uniqueness: true, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :timezone, presence: true, inclusion: { in: TZInfo::Timezone.all_identifiers,
                                                    message: "This is not a valid timezone" }

  has_one :coach_profile, dependent: :destroy

  # For students
  has_many :coaching_sessions_as_student, class_name: "CoachingSession", foreign_key: "student_id"
  has_many :booked_sessions, class_name: "Availability", foreign_key: "student_id"
  has_many :coaching_sessions_as_student, class_name: "CoachingSession", foreign_key: "student_id"


  after_create :create_coach_profile_if_coach

  def self.active_coaches
    where(role: UserRoles::COACH)
    .joins(:coach_profile)
    .where(coach_profiles: { active: true })
    .order(:name)
  end

  def availabilities
    return [] unless coach?
    coach_profile&.availabilities || []
  end
  def create_availability(start_time, end_time = nil)
    return false unless coach?
    return false unless coach_profile

    # If end_time is not provided, default to 2 hours after start_time
    end_time ||= start_time + 2.hours

    coach_profile.availabilities.create(
      start_time: start_time,
      end_time: end_time,
      status: "available"
    )
  end

  # Get all available (not booked) upcoming availabilities
  def available_slots
    return [] unless coach?
    availabilities.upcoming.available.order(start_time: :asc)
  end

  def available_slots_by_range(start_time, end_time)
    availabilities.available
                  .where(start_time: start_time.beginning_of_day..end_time.end_of_day)
                  .order(start_time: :asc)
  end

  # Get all booked upcoming availabilities
  def booked_slots
    return [] unless coach?
    availabilities.upcoming.where(status: "booked").order(start_time: :asc)
  end

  def availabilities_by_date(start_date = Date.today, end_date = 4.weeks.from_now.to_date)
    return {} unless coach?

    date_range = (start_date.to_date..end_date.to_date).to_a
    availabilities_in_range = availabilities
                                .where(start_time: start_date.beginning_of_day..end_date.end_of_day)
                                .order(start_time: :asc)

    # Group by date
    result = date_range.each_with_object({}) do |date, hash|
      hash[date] = []
    end

    availabilities_in_range.each do |availability|
      date = availability.start_time.to_date
      result[date] ||= []
      result[date] << availability
    end

    result
  end

  def upcoming_coaching_sessions
    if coach?
      # For coaches: find their upcoming sessions that are booked
      coach_profile.upcoming_sessions
    else
      # For students: find their upcoming booked sessions
      coaching_sessions_as_student
        .joins(:availability)
        .where(status: 'scheduled')
        .where('availabilities.start_time > ?', Time.current)
        .where('availabilities.status = ?', 'booked')  # Add this line
        .order('availabilities.start_time ASC')
    end
  end

  # Methods for student functionality
  # Method to get upcoming booked sessions (for students)
  def upcoming_booked_sessions
    return [] unless student?
    booked_sessions.upcoming.order(start_time: :asc)
  end

  # Method to get past booked sessions (for students)
  def past_booked_sessions
    return [] unless student?
    booked_sessions.past.order(start_time: :desc)
  end

  def completed_coaching_sessions
    return [] unless coach?
    coach_profile.coaching_sessions.completed.order("completed_at DESC")
  end

  def pending_feedback_sessions
    return [] unless coach?
    coach_profile.coaching_sessions
                 .joins(:availability)
                 .where("availabilities.end_time < ?", Time.current)
                 .where(status: "scheduled")
                 .order("availabilities.start_time ASC")
  end

  def book_availability(availability_id)
    return false unless student?

    availability = Availability.find_by(id: availability_id, status: "available")
    return false unless availability

    # Try to book the availability
    availability.book!(self)
  end

  def cancel_booking(booking_id)
    return false unless student?

    availability = booked_sessions.find_by(id: booking_id)
    return false unless availability

    # Only allow cancellation for future sessions
    return false if availability.start_time <= Time.current

    # Try to cancel the booking
    availability.cancel_booking!
  end

  private

  def create_coach_profile_if_coach
    if coach? && !coach_profile
      create_coach_profile
    end
  end
end
