# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::Inspections::Operations::Create do
  subject(:result) { described_class.call(params:, current_user:) }

  let(:params) { { visit_id: '12', breeding_site_type_id: '3', type_content_ids: ['5'] } }
  let(:current_user) { instance_double(UserAccount) }
  let(:visit_user) { instance_double(UserAccount) }
  let(:inspection) { instance_double(Inspection) }
  let(:inspections) { double }
  let(:house_blocks) { double }
  let(:visited_at) { Time.zone.parse('2026-07-20 10:00:00') }
  let(:visit) do
    instance_double(
      Visit,
      house:,
      inspections:,
      team_id: 8,
      user_account: visit_user,
      visited_at:
    )
  end
  let(:house) do
    instance_double(
      House,
      city_id: 1,
      country_id: 2,
      house_blocks:,
      id: 9,
      infected_containers: 0,
      last_visit: visited_at,
      neighborhood_id: 3,
      non_infected_containers: 0,
      potential_containers: 1,
      reload: nil,
      status: Constants::RiskColor::YELLOW,
      wedge_id: 4
    )
  end
  let(:house_status) { instance_double(HouseStatus, assign_attributes: true, save!: true) }
  let(:expected_attributes) do
    {
      breeding_site_type_id: 3,
      type_content_ids: [5],
      color: Constants::RiskColor::YELLOW,
      created_by: current_user,
      has_water: true,
      treated_by: visit_user
    }
  end

  before do
    allow(BreedingSiteType).to receive(:exists?).with(id: 3).and_return(true)
    allow(TypeContent).to receive(:where).with(id: [5]).and_return(
      instance_double(ActiveRecord::Relation, count: 1)
    )
    allow(Visit).to receive(:find_by).with(id: 12).and_return(visit)
    allow(ActiveRecord::Base).to receive(:transaction).and_yield
    allow(Services::RiskColorCalculator).to receive(:inspection_color).and_return(Constants::RiskColor::YELLOW)
    allow(inspections).to receive(:create!).and_return(inspection)
    allow(Services::VisitHouseStatusUpdater).to receive(:apply_and_tariki_reached?).and_return(false)
    allow(house).to receive(:reload).and_return(house)
    allow(house_blocks).to receive(:find_by).and_return(nil)
    allow(HouseStatus).to receive(:find_or_initialize_by).and_return(house_status)
  end

  it 'creates a container with server-derived attributes' do
    expect(inspections).to receive(:create!).with(expected_attributes).and_return(inspection)

    expect(result).to be_success
    expect(result.value![:type]).to eq(:created)
    expect(result.value![:ctx][:model]).to eq(inspection)
  end
end
