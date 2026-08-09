# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('app/lib/services/visit_house_status_updater')

RSpec.describe Services::VisitHouseStatusUpdater do
  describe '.apply_and_tariki_reached?' do
    subject(:apply_status) { described_class.apply_and_tariki_reached?(visit:) }

    let(:visit) { instance_double(Visit, house:, visited_at:) }
    let(:house) { instance_double(House, tariki_status: false, tariki_status?: true) }
    let(:visited_at) { Time.zone.parse('2026-08-08 10:00:00') }
    let(:status) { Constants::RiskColor::GREEN }
    let(:counts) do
      {
        infected_containers: 0,
        potential_containers: 0,
        non_infected_containers: 1
      }
    end

    before do
      allow(Services::RiskColorCalculator).to receive(:visit_snapshot).with(visit).and_return(status:, counts:)
      allow(Services::TarikiStatusRecalculator).to receive(:recalculate!).with(house)
      allow(visit).to receive(:update!)
      allow(house).to receive(:update!)
    end

    it 'updates the visit and its house using the visit timestamp' do
      expect(visit).to receive(:update!).with(status:)
      expect(house).to receive(:update!).with(**counts, last_visit: visited_at, status:)

      expect(apply_status).to be(true)
    end

    context 'when the visit timestamp is missing' do
      let(:visited_at) { nil }

      it 'uses the current time' do
        travel_to(Time.zone.parse('2026-08-09 11:00:00')) do
          expect(house).to receive(:update!).with(**counts, last_visit: Time.current, status:)

          apply_status
        end
      end
    end
  end
end
