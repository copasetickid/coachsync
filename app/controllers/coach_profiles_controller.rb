# app/controllers/coach_profiles_controller.rb
class CoachProfilesController < ApplicationController
  before_action :set_user
  before_action :set_coach_profile, except: [:new, :create]
  before_action :ensure_coach_user, except: [:show]
  before_action :ensure_coach_or_self, only: [:show]
  before_action :ensure_owner, only: [:edit, :update, :toggle_active]

  # GET /users/:user_id/coach_profile
  def show
    if @coach_profile.nil?
        redirect_to root_path, alert: "This user does not have a coach profile."
    end

    @upcoming_availabilities = @coach_profile.availabilities
                                             .upcoming
                                             .where(status: "available")
                                             .order(start_time: :asc)
                                             .limit(10)

    @recent_sessions = @coach_profile.coaching_sessions
                                     .past
                                     .includes(:student, :availability)
                                     .order('availabilities.end_time DESC')
                                     .limit(10)
  end

  # GET /users/:user_id/coach_profile/new
  def new
    if @user.coach_profile.present?
      redirect_to user_coach_profile_path(@user), notice: "Coach profile already exists."
      return
    end

    @coach_profile = CoachProfile.new
  end

  # POST /users/:user_id/coach_profile
  def create
    if @user.coach_profile.present?
      redirect_to user_coach_profile_path(@user), alert: "Coach profile already exists."
      return
    end

    @coach_profile = @user.build_coach_profile(coach_profile_params)

    if @coach_profile.save
      redirect_to user_coach_profile_path(@user), notice: "Coach profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:user_id/coach_profile/edit
  def edit
    if @coach_profile.nil?
      redirect_to new_user_coach_profile_path(@user)
    end
  end

  # PATCH/PUT /users/:user_id/coach_profile
  def update
    if @coach_profile.update(coach_profile_params)
      redirect_to user_coach_profile_path(@user), notice: "Coach profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /users/:user_id/coach_profile/toggle_active
  def toggle_active
    @coach_profile.update(active: !@coach_profile.active)
    status = @coach_profile.active? ? "active" : "inactive"
    redirect_to user_coach_profile_path(@user), notice: "Coach profile status changed to #{status}."
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_coach_profile
    @coach_profile = @user.coach_profile
  end

  def ensure_coach_user
    unless @user.coach?
      redirect_to root_path, alert: "This user is not a coach."
    end
  end

  def ensure_coach_or_self
    unless @user == current_user || (@coach_profile&.active? && @user.coach?)
      redirect_to root_path, alert: "You don't have access to this profile."
    end
  end

  def ensure_owner
    unless @user == current_user
      redirect_to root_path, alert: "You can only edit your own coach profile."
    end
  end

  def coach_profile_params
    params.require(:coach_profile).permit(
      :bio,
      :active,
    )
  end
end