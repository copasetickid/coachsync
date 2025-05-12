require 'rails_helper'

RSpec.describe SessionFeedbacksController, type: :controller do
  let(:coach_user) { create(:user, :coach) }
  let(:student_user) { create(:user, :student) }
  let(:coach_profile) { coach_user.coach_profile }

  # Create a past availability that's properly in the past
  let(:past_availability) do
    create(:availability,
           coach_profile: coach_profile,
           start_time: 2.days.ago.change(hour: 14, min: 0, sec: 0),
           end_time: 2.days.ago.change(hour: 16, min: 0, sec: 0),
           status: "booked"
    )
  end

  let!(:coaching_session) do
    create(:coaching_session,
           coach_profile: coach_profile,
           student: student_user,
           availability: past_availability,
           status: "scheduled"
    )
  end

  describe 'GET #index' do
    context 'as a coach' do
      before do
        session[:user_id] = coach_user.id
        allow(controller).to receive(:current_user).and_return(coach_user)
      end

      it 'returns success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns pending sessions' do
        get :index

        # Debug output if needed
        if assigns(:pending_feedback_sessions).nil?
          puts "Pending sessions is nil"
          puts "Coach profile sessions: #{coach_profile.coaching_sessions.count}"
          puts "Session details: #{coaching_session.inspect}"
        end

        expect(assigns(:pending_feedback_sessions)).not_to be_nil
        expect(assigns(:pending_feedback_sessions)).to include(coaching_session)
      end
    end

    context 'as a student' do
      before do
        session[:user_id] = student_user.id
        allow(controller).to receive(:current_user).and_return(student_user)
      end

      it 'redirects to root' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
