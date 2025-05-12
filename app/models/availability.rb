class Availability < ApplicationRecord
  belongs_to :coach_profile
  belongs_to :student, class_name: "User", optional: true
  has_one :coaching_session

  validates :coach_profile_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: %w[available booked] }


  validate :slot_is_two_hours
  validate :no_overlapping_slots
  validate :student_has_student_role, if: -> { student.present? }

  before_validation :set_end_time, if: -> { start_time.present? && end_time.blank? }

  scope :available, -> { where(status: "available") }
  scope :upcoming, -> { where("start_time > ?", Time.current).order(start_time: :asc) }
  scope :past, -> { where("start_time < ?", Time.current).order(start_time: :desc) }
  scope :booked, -> { where(status: "booked") }


  def coach
    coach_profile.user
  end

  def time_range_string
    "#{start_time.strftime('%I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end

  def date_string
    start_time.strftime("%A, %B %d, %Y")
  end

  def short_date_string
    start_time.strftime("%m/%d/%y")
  end

  def available?
    status == "available"
  end

  def booked?
    status == "booked"
  end

  def book!(student)
    return false unless available?
    return false unless student.student?

    transaction do
      # Update this availability
      self.student = student
      self.status = "booked"

      # Create a coaching session record
      cs = CoachingSession.new(
        coach_profile: coach_profile,
        availability: self,
        student: student,
        status: "scheduled"
      )

      # Save both records
      save && cs.save
    end
  end

  def cancel_booking!
    # return false unless booked?
    #
    # transaction do
    #   # Update the coaching session
    #   if coaching_session
    #     coaching_session.update(status: "cancelled")
    #   end
    #
    #   # Reset the availability
    #   self.status = "available"
    #   self.student = nil
    #   save
    # end
    # Let's use a more explicit approach
    raise "Cannot cancel - availability not booked" unless booked?

    transaction do
      # First, find the coaching session explicitly
      session = CoachingSession.find_by(availability_id: self.id)

      if session
        Rails.logger.debug "Found coaching session #{session.id} for availability #{self.id}"
        session.update!(status: "cancelled")
      else
        Rails.logger.warn "No coaching session found for availability #{self.id}"
      end

      # Update availability
      update!(
        status: "available",
        student_id: nil
      )
    end

    true
  end

  def coach_name
    coach_profile.user.name
  end

  def student_name
    student&.name || "No student"
  end

  def coaching_session_id
    coaching_session&.id || "No coaching session"
  end

  private

  def student_has_student_role
    unless student.student?
      errors.add(:student, "must have a student role")
    end
  end


  def slot_is_two_hours
    return unless start_time && end_time
    duration = ((end_time - start_time) / 1.hour)


    unless (duration - 2.0).abs < 0.001
      errors.add(:base, "Slot must be exactly 2 hours")
    end
  end

  def no_overlapping_slots
    return unless coach_profile && start_time && end_time


    overlaps = coach_profile.availabilities
                            .where.not(id: id)
                            .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?)",
                                   end_time, start_time, end_time, start_time)

    errors.add(:base, "This slot overlaps with an existing availability") if overlaps.exists?
  end

  def set_end_time
    self.end_time = start_time + 2.hours
  end

end
