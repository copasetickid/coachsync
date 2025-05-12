# app/controllers/availabilities_controller.rb
class AvailabilitiesController < ApplicationController
  before_action :set_coach
  before_action :ensure_coach_or_self, only: [:index]
  before_action :ensure_self, only: [:new, :create, :destroy]

  def index
    @today = Time.current
    @availabilities = @coach.availabilities_by_date(@today, 4.weeks.from_now.to_date)
    @upcoming_availabilities = @coach.available_slots.limit(20)
    @booked_availabilities = @coach.booked_slots.limit(20)

    @availabilities_by_time = {}

    prepare_calendar_data
  end

  def new
    @availability = Availability.new
  end

  def create
    date = params[:availability][:date]
    start_time = params[:availability][:start_time]
    # time_zone = params[:availability][:time_zone] || @coach.timezone || Time.zone.name
    datetime_str = "#{date} #{start_time}"
    start_datetime = Time.zone.parse(datetime_str)


    result = @coach.create_availability(start_datetime)

    if result
      redirect_to user_availabilities_path(@coach), notice: "Availability slot created successfully."
    else
      @availability = Availability.new
      flash.now[:alert] = "Failed to create availability slot. It may overlap with an existing slot."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    availability = @coach.availabilities.find(params[:id])

    if availability.destroy
      redirect_to coach_availabilities_path(@coach), notice: "Availability was successfully removed."
    else
      redirect_to coach_availabilities_path(@coach), alert: "Failed to remove availability."
    end
  end

  private

  def set_coach
    user_id = params[:user_id] || params[:coach_id]
    @coach = User.find(user_id)
  end

  def ensure_coach_or_self
    unless @coach == current_user || (@coach.coach_profile.active? && @coach.coach?)
      redirect_to root_path, alert: "You don't have access to this coach's availabilities."
    end
  end

  def ensure_self
    unless @coach == current_user
      redirect_to root_path, alert: "You can only manage your own availabilities."
    end
  end

  def prepare_calendar_data
    # Get a week of availabilities for the calendar view
    end_date = @today + 6.days
    availabilities = @coach.availabilities
                           .where(start_time: @today.beginning_of_day..end_date.end_of_day)
                           .order(start_time: :asc)

    # Index availabilities by hour for the calendar
    @availabilities_by_time = {}

    availabilities.each do |availability|
      # Round to the nearest hour for display purposes
      hour_key = availability.start_time.strftime("%Y-%m-%d %H:00")
      @availabilities_by_time[hour_key] = availability
    end
  end
end
