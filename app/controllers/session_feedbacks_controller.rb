class SessionFeedbacksController < ApplicationController
  before_action :ensure_coach
  before_action :set_coaching_session, only: [:edit, :update]

  def index
    # Get the coach profile for the current user
    @coach_profile = current_user.coach_profile

    # Get upcoming sessions for this coach
    @upcoming_sessions = @coach_profile.coaching_sessions
                                       .scheduled
                                       .joins(:availability)
                                       .where('availabilities.start_time > ?', Time.current)
                                       .includes([:student, :availability])
                                       .order('availabilities.start_time ASC')


    # Get past sessions for this coach that need feedback
    @pending_feedback_sessions = @coach_profile.coaching_sessions
                                               .scheduled
                                               .joins(:availability)
                                               .where("availabilities.end_time < ?", Time.current)
                                               .includes(:student, :availability)
                                               .order("availabilities.end_time DESC")

    # Get completed sessions with feedback
    @completed_sessions = @coach_profile.coaching_sessions
                                        .completed
                                        .includes(:student, :availability)
                                        .order("updated_at DESC")
  end

  def edit
    # Show the form to provide feedback for a completed session
    if @coaching_session.status != "scheduled" || @coaching_session.availability.end_time > Time.current
      redirect_to session_feedbacks_path, alert: "You cannot provide feedback for this session yet."
    end
  end

  def update
    # Save the feedback
    if @coaching_session.status == "scheduled" && @coaching_session.availability.end_time < Time.current
      if @coaching_session.update(
        status: "completed",
        satisfaction_score: params[:coaching_session][:satisfaction_score],
        notes: params[:coaching_session][:notes]
      )
        redirect_to session_feedbacks_path, notice: "Feedback provided successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to session_feedbacks_path, alert: "You cannot provide feedback for this session."
    end
  end

  private

  def set_coaching_session
    @coaching_session = current_user.coach_profile.coaching_sessions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to session_feedbacks_path, alert: "Coaching session not found."
  end

  def ensure_coach
    unless current_user.coach? && current_user.coach_profile
      redirect_to root_path, alert: "Only coaches can access this section."
    end
  end
end