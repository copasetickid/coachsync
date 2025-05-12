require 'rails_helper'

RSpec.describe CoachingSession, type: :model do
    describe 'associations' do
      it { should belong_to(:coach_profile) }
      it { should belong_to(:student).class_name('User') }
      it { should belong_to(:availability) }
    end

    describe 'validations' do
      it { should validate_inclusion_of(:status).in_array(%w[scheduled completed cancelled]) }
    end

    describe 'satisfaction_score validation' do
      context 'when present' do
        it { should validate_numericality_of(:satisfaction_score)
                      .is_greater_than_or_equal_to(1)
                      .is_less_than_or_equal_to(5) }
      end

      context 'when nil' do
        it 'allows nil satisfaction_score' do
          coach = create(:user, :coach)
          student = create(:user, :student)
          ava = create(:availability,
                       coach_profile: coach.coach_profile)
          session = create(:coaching_session,
                           coach_profile: coach.coach_profile,
                           student: student,
                           availability: ava,
                           satisfaction_score: nil)
          expect(session).to be_valid
        end
      end
    end

    describe 'scopes' do
      let!(:coach) { create(:user, :coach) }
      let!(:student) { create(:user, :student) }

      let(:past_time) { 6.hours.ago }

      let(:future_time) { 2.hours.from_now }

      let!(:ava1) { create(:availability,
                    coach_profile: coach.coach_profile,
                           start_time: past_time, end_time: past_time + 2.hours ) }
      let!(:ava2) { create(:availability,
                    coach_profile: coach.coach_profile,
                    start_time: 1.day.ago,
                           end_time: 1.day.ago + 2.hours
      ) }
      let!(:ava3) { create(:availability,
                    coach_profile: coach.coach_profile,
                    start_time: 2.days.ago,
                           end_time: 2.days.ago + 2.hours ) }

      let!(:scheduled_session) { create(:coaching_session,
                                        coach_profile: coach.coach_profile,
                                        student: student,
                                        availability: ava1) }
      let!(:completed_session) { create(:coaching_session, :completed,
                                        coach_profile: coach.coach_profile,
                                        student: student,
                                        availability: ava2) }
      let!(:cancelled_session) { create(:coaching_session, :cancelled,
                                        coach_profile: coach.coach_profile,
                                        student: student,
                                        availability: ava3) }

      describe '.scheduled' do
        it 'returns only scheduled sessions' do
          expect(CoachingSession.scheduled).to eq([scheduled_session])
        end
      end

      describe '.completed' do
        it 'returns only completed sessions' do
          expect(CoachingSession.completed).to eq([completed_session])
        end
      end

      describe '.cancelled' do
        it 'returns only cancelled sessions' do
          expect(CoachingSession.cancelled).to eq([cancelled_session])
        end
      end

      describe '.upcoming' do
        let(:future_time) { 1.day.from_now}
        let(:last_week) { 1.week.ago }
        let(:future_availability) { create(:availability, coach_profile: coach.coach_profile,
                                           start_time: future_time, end_time: future_time + 2.hours) }
        let(:past_availability) { create(:availability,
                                         coach_profile: coach.coach_profile,
                                         start_time: last_week,
                                         end_time: last_week + 2.hours) }

        let!(:future_session) { create(:coaching_session,
                                       coach_profile: coach.coach_profile,
                                       student: student,
                                       availability: future_availability) }
        let!(:past_session) { create(:coaching_session,
                                     student: student,
                                     coach_profile: coach.coach_profile,
                                     availability: past_availability) }

        it 'returns only sessions with future start times' do
          expect(CoachingSession.upcoming).to eq([future_session])
        end
      end
    end



  end
