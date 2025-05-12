require 'rails_helper'

RSpec.describe CoachingSessionsController, type: :controller do
  let(:coach_user) { create(:user, :coach) }
  let(:student_user) { create(:user, :student) }
  let(:coach_profile) { coach_user.coach_profile }

  let(:future_availability) do
    create(:availability,
           coach_profile: coach_profile,
           start_time: 2.days.from_now,
           end_time: 2.days.from_now + 2.hours,
           status: "booked"
    )
  end

  let(:coaching_session) { create(:coaching_session,
                                  coach_profile: coach_profile,
                                  student: student_user,
                                  availability: future_availability,
                                  status: "scheduled")
  }


  describe 'GET #show' do
    context 'as the student' do
      before do
        session[:user_id] = student_user.id
        allow(controller).to receive(:current_user).and_return(student_user)
      end

      it 'returns success' do
        get :show, params: { id: coaching_session.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the coaching session' do
        get :show, params: { id: coaching_session.id }
        expect(assigns(:coaching_session)).to eq(coaching_session)
      end
    end

    context 'as the coach' do
      before do
        session[:user_id] = coach_user.id
        allow(controller).to receive(:current_user).and_return(coach_user)
      end

      it 'returns success' do
        get :show, params: { id: coaching_session.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'as another user' do
      let(:other_user) { create(:user, :student) }
      before do
        session[:user_id] = other_user.id
        allow(controller).to receive(:current_user).and_return(other_user)
      end

      it 'redirects with unauthorized message' do
        get :show, params: { id: coaching_session.id }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to include('not authorized')
      end
    end
  end
end