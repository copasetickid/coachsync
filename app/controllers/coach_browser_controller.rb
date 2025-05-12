class CoachBrowserController < ApplicationController
  before_action :ensure_student

  def index
    @coaches = User.active_coaches
  end

  def show
    @coach = User.find(params[:id])

    unless @coach.coach? && @coach.coach_profile&.active?
      redirect_to coach_browser_index_path, alert: "This coach is not available."
      return
    end

    # Get the current week's dates (starting from today)
    @today = Date.today
    @end_date = @today + 13.days # Show two weeks of availability

    # Get available slots for this coach within the date range
    @available_slots = @coach.coach_profile.availabilities
                             .where(status: "available")
                             .where(start_time: @today.beginning_of_day..@end_date.end_of_day)
                             .order(start_time: :asc)

    # Group available slots by date for easier display
    @slots_by_date = @available_slots.group_by { |slot| slot.start_time.to_date }
  end

  private

  def ensure_student
    unless current_user.student?
      redirect_to root_path, alert: "Only students can browse coaches."
    end
  end
end