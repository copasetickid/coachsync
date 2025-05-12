class CoachingSessionsController < ApplicationController
  before_action :set_coaching_session
  before_action :authorize_user


  def show
    # The coaching session detail page
    @coach = @coaching_session.coach_profile.user
    @student = @coaching_session.student
    @availability = @coaching_session.availability
  end

  def update
    # Update notes or other details about the session
    if @coaching_session.update(coaching_session_params)
      redirect_to coaching_session_path(@coaching_session), notice: "Session updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def complete
    # Mark a session as completed with feedback
    if @coaching_session.status == "scheduled" && @coaching_session.availability.end_time < Time.current
      if @coaching_session.update(
        status: "completed",
        satisfaction_score: params[:satisfaction_score],
        notes: params[:notes]
      )
        redirect_to session_feedbacks_path, notice: "Session marked as completed."
      else
        redirect_to coaching_session_path(@coaching_session), alert: "Unable to complete the session."
      end
    else
      redirect_to coaching_session_path(@coaching_session), alert: "This session cannot be marked as completed."
    end
  end

  def cancel
    # Cancel an upcoming session
    if @coaching_session.status == "scheduled" && @coaching_session.availability.start_time > Time.current
      ActiveRecord::Base.transaction do
        # Update the coaching session
        @coaching_session.update!(status: "cancelled")

        # Reset the availability
        @coaching_session.availability.update!(
          status: "available",
          student_id: nil
        )
      end

      redirect_to session_feedbacks_path, notice: "Session cancelled successfully."
    else
      redirect_to coaching_session_path(@coaching_session), alert: "This session cannot be cancelled."
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to coaching_session_path(@coaching_session), alert: "Failed to cancel the session."
  end

  private

  def set_coaching_session
    @coaching_session = CoachingSession.find(params[:id])
  end

  def authorize_user
    # Only the coach or student involved in the session can access it
    unless current_user == @coaching_session.coach_profile.user || current_user == @coaching_session.student
      redirect_to root_path, alert: "You are not authorized to view this session."
    end
  end

  def coaching_session_params
    params.require(:coaching_session).permit(:notes)
  end
end