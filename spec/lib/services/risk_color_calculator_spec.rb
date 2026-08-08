# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('app/lib/services/risk_color_calculator')

RSpec.describe Services::RiskColorCalculator do
  describe '.visit_snapshot' do
    subject(:snapshot) { described_class.visit_snapshot(visit) }

    let(:inspections) { instance_double(ActiveRecord::Associations::CollectionProxy) }
    let(:visit) do
      instance_double(
        Visit,
        inspections:,
        visit_permission_granted?: permission_granted
      )
    end
    let(:permission_granted) { false }
    let(:color_counts) { {} }

    before do
      allow(inspections).to receive(:group).with(:color).and_return(inspections)
      allow(inspections).to receive(:count).and_return(color_counts)
    end

    context 'when the visit has no inspections and permission was denied' do
      it 'returns yellow with empty container counts' do
        expect(snapshot).to eq(
          status: Constants::RiskColor::YELLOW,
          counts: {
            infected_containers: 0,
            potential_containers: 0,
            non_infected_containers: 0
          }
        )
      end
    end

    context 'when the visit has no inspections and permission was granted' do
      let(:permission_granted) { true }

      it 'returns green with empty container counts' do
        expect(snapshot).to eq(
          status: Constants::RiskColor::GREEN,
          counts: {
            infected_containers: 0,
            potential_containers: 0,
            non_infected_containers: 0
          }
        )
      end
    end

    context 'when the visit has a red inspection' do
      let(:color_counts) { { Constants::RiskColor::RED => 1 } }

      it 'derives red from the inspection' do
        expect(snapshot).to eq(
          status: Constants::RiskColor::RED,
          counts: {
            infected_containers: 1,
            potential_containers: 0,
            non_infected_containers: 0
          }
        )
      end
    end
  end
end
