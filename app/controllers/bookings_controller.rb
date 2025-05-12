
class BookingsController < ApplicationController
  before_action :ensure_student

  def index
    @upcoming_bookings = current_user.upcoming_booked_sessions
    @past_bookings = current_user.past_booked_sessions
  end

  def create
    availability_id = params[:availability_id]
    availability = Availability.find_by(id: availability_id, status: "available")

    if availability.nil?
      redirect_back fallback_location: coach_browser_index_path,
                    alert: "This slot is no longer available."
      return
    end

    # Attempt to book the slot
    if current_user.book_availability(availability_id)
      redirect_to bookings_path, notice: "Session booked successfully with #{availability.coach_name}."
    else
      redirect_back fallback_location: coach_browser_index_path,
                    alert: "Unable to book this session. It may no longer be available."
    end
  end

  def destroy
    booking = current_user.booked_sessions.find_by(id: params[:id])

    if booking.nil?
      redirect_to bookings_path, alert: "Booking not found."
      return
    end

    # Check if the booking is in the future (can be cancelled)
    if booking.start_time <= Time.current
      redirect_to bookings_path, alert: "Cannot cancel sessions that have already started or ended."
      return
    end

    if current_user.cancel_booking(booking.id)
      redirect_to bookings_path, notice: "Booking cancelled successfully."
    else
      redirect_to bookings_path, alert: "Unable to cancel this booking."
    end
  end

  private

  def ensure_student
    unless current_user.student?
      redirect_to root_path, alert: "Only students can manage bookings."
    end
  end
end