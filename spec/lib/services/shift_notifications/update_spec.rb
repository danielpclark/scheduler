# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::ShiftNotifications::Update do
  let(:office) { create(:office) }
  let(:coordinator) { create(:user, role: 'coordinator', offices: [office]) }
  let(:need) { create(:need_with_shifts, user: coordinator, office: office) }
  let(:shift) { need.shifts.first }
  let(:volunteer) { create(:user, offices: [office]) }
  let!(:social_worker) { create(:user, role: 'social_worker', offices: [office]) }

  describe '#call' do
    context 'when a volunteer' do
      context 'assigns themself to a shift' do
        it 'notifies the social workers' do
          shift.assign_attributes(user_id: volunteer.id)
          expect(described_class.call(shift, volunteer, nil)).to include(social_worker)
        end

        it 'notifies the need creator' do
          shift.assign_attributes(user_id: volunteer.id)
          expect(described_class.call(shift, volunteer, nil)).to include(coordinator)
        end
      end

      context 'unassigns themself from a shift' do
        before { shift.update(user: volunteer) }

        it 'notifies the social workers' do
          shift.assign_attributes(user_id: nil)
          expect(described_class.call(shift, volunteer, volunteer.id)).to include(social_worker)
        end

        it 'notifies the need creator' do
          shift.assign_attributes(user_id: nil)
          expect(described_class.call(shift, volunteer, volunteer.id)).to include(coordinator)
        end
      end
    end

    context 'when a scheduler' do
      context 'assigns a volunteer' do
        it 'notifies the user being assigned' do
          shift.assign_attributes(user_id: volunteer.id)
          expect(described_class.call(shift, social_worker, nil)).to include(volunteer)
        end
      end

      context 'unassigns a volunteer' do
        before { shift.update(user: volunteer) }

        it 'notifies the user being unassigned' do
          shift.assign_attributes(user_id: nil)
          expect(described_class.call(shift, social_worker, volunteer.id)).to include(volunteer)
        end
      end
    end

  end

end
