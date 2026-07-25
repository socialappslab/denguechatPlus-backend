# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::TarikiStatusRecalculator do
  describe '.call' do
    let(:state) { { tariki_status: true, consecutive_green_status: 4 } }
    let(:house) do
      instance_double(
        House,
        tariki_status: false,
        consecutive_green_status: 3
      )
    end

    before do
      allow(AppConfigParam).to receive(:tariki_required_green_visits).and_return(4)
      allow(AppConfigParam).to receive(:tariki_time_window).and_return(2.months)
      allow(House).to receive(:find_each).and_yield(house)
      allow(house).to receive(:with_lock).and_yield
      allow(house).to receive(:current_tariki_state).and_return(state)
      allow(house).to receive(:update_columns)
    end

    it 'updates both persisted Tariki values from the same calculation' do
      expect(described_class.call).to eq(1)
      expect(house).to have_received(:current_tariki_state).with(
        required_green_visits: 4,
        time_window: 2.months
      )
      expect(house).to have_received(:update_columns).with(
        tariki_status: true,
        consecutive_green_status: 4,
        updated_at: kind_of(ActiveSupport::TimeWithZone)
      )
    end
  end
end
