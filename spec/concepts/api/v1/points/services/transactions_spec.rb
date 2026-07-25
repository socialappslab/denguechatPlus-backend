# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::Points::Services::Transactions do
  describe '.assign_point' do
    subject(:assign_point) do
      described_class.assign_point(earner: user_account, house_id:, visit_id:)
    end

    let(:house_id) { 17 }
    let(:visit_id) { 29 }
    let(:visited_at) { Time.zone.parse('2026-07-20 10:00') }
    let(:user_account) { UserAccount.new }
    let(:team) { Team.new }
    let(:visit) { instance_double(Visit, team:, user_account:, visited_at:) }
    let(:user_points) { double }
    let(:team_points) { double }
    let(:user_point) { instance_double(Point) }
    let(:team_point) { instance_double(Point) }

    before do
      allow(Visit).to receive(:find_by).with(id: visit_id).and_return(visit)
      allow(user_account).to receive(:points).and_return(user_points)
      allow(team).to receive(:points).and_return(team_points)
      allow(user_points).to receive(:joins).with(:visit).and_return(user_points)
      allow(user_points).to receive(:where)
        .with(house_id:, visits: { visited_at: visited_at.all_day })
        .and_return(user_points)
    end

    context 'when no points have been awarded for the house on the visit day' do
      before do
        allow(user_points).to receive(:first).and_return(nil)
        allow(AppConfigParam).to receive(:find_by)
          .with('name = ?', 'green_house_points_user_account')
          .and_return(instance_double(AppConfigParam, value: '10'))
        allow(AppConfigParam).to receive(:find_by)
          .with('name = ?', 'green_house_points_team')
          .and_return(instance_double(AppConfigParam, value: '20'))
        allow(user_points).to receive(:create!)
          .with(value: '10', house_id:, visit_id:)
          .and_return(user_point)
        allow(team_points).to receive(:create!)
          .with(value: '20', house_id:, visit_id:)
          .and_return(team_point)
      end

      it 'returns the persisted point records' do
        expect(assign_point).to eq([user_point, team_point])
      end
    end

    context 'when points have already been awarded for the house on the visit day' do
      before do
        allow(user_points).to receive(:first).and_return(instance_double(Point))
      end

      it 'does not persist or return another award' do
        expect(user_points).not_to receive(:create!)
        expect(team_points).not_to receive(:create!)

        expect(assign_point).to eq([])
      end
    end
  end
end
