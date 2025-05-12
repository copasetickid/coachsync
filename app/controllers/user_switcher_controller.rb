# app/controllers/user_switcher_controller.rb
class UserSwitcherController < ApplicationController
  before_action :ensure_development_or_test
  # skip_before_action :authenticate_user!, only: [:index, :switch, :reset]

  def index
    @coaches = User.where(role: UserRoles::COACH).order(:name)
    @students = User.where(role: UserRoles::STUDENT).order(:name)
    @current_user_id = session[:user_id]

    # Store original user ID if we haven't already
    unless session[:original_user_id]
      session[:original_user_id] = session[:user_id]
    end
  end

  def switch
    # Store the original user ID if not already stored
    unless session[:original_user_id]
      session[:original_user_id] = session[:user_id]
    end

    # Simple approach: directly replace the user_id in session
    session[:user_id] = params[:user_id]

    redirect_to root_path, notice: "Switched to #{User.find(params[:user_id]).name}"
  end

  def reset
    # # Reset to original user if available
    # if session[:original_user_id]
    #   session[:user_id] = session[:original_user_id]
    #   session.delete(:original_user_id)
    #   redirect_to root_path, notice: "Reset to original user"
    # else
    #   redirect_to root_path, alert: "No original user found"
    # end

    reset_session
    # Clear any custom session variables
    session.delete(:user_id)
    session.delete(:switched_from)
    session.delete(:original_user_id)



    # Clear any instance variables
    @current_user = nil

    redirect_to root_path, notice: "Session cleared. Please sign in again."
  end

  private

  def ensure_development_or_test
    unless Rails.env.development? || Rails.env.test?
      redirect_to root_path, alert: "Not available in this environment"
    end
  end
end