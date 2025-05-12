class HomeController < ApplicationController

  def index
    if user_signed_in?
      if current_user.coach?
        @upcoming_sessions = current_user.upcoming_coaching_sessions.limit(5)
        @coach_profile = current_user.coach_profile
        @pending_feedback = current_user.pending_feedback_sessions.limit(5)
      elsif current_user.student?
        @upcoming_sessions = current_user.coaching_sessions_as_student.scheduled.upcoming.limit(5)
        @available_coaches = User.active_coaches.limit(6)
      end
      render :dashboard
    else
      render :landing
    end

  end

end
