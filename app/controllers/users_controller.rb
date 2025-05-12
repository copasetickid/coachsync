# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_current_user, only: [:edit, :update]

  def show
    if @user.coach? && @user.coach_profile.active?
      @upcoming_availabilities = @user.coach_profile.availabilities
                                      .upcoming
                                      .available
                                      .order(start_time: :asc)
                                      .limit(5)
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Your profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_current_user
    unless @user == current_user
      redirect_to root_path, alert: 'You can only edit your own profile.'
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :timezone, :phone)
  end
end