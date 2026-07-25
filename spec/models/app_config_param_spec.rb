# frozen_string_literal: true

# == Schema Information
#
# Table name: app_config_params
#
#  id           :bigint           not null, primary key
#  description  :string
#  discarded_at :datetime
#  name         :string
#  param_source :string
#  param_type   :string
#  value        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_app_config_params_on_name                   (name) UNIQUE
#  index_app_config_params_on_param_source_and_name  (param_source,name)
#
require 'spec_helper'

RSpec.describe AppConfigParam do
  describe '.tariki_required_green_visits' do
    let(:param) do
      described_class.create!(
        name: described_class::TARIKI_REQUIRED_GREEN_VISITS_NAME,
        value: described_class::DEFAULT_TARIKI_REQUIRED_GREEN_VISITS.to_s
      )
    end

    it 'returns the configured positive integer' do
      param.update!(value: '6')

      expect(described_class.tariki_required_green_visits).to eq(6)
    end

    it 'uses the default for an invalid value' do
      param.update_column(:value, '4oops') # rubocop:disable Rails/SkipsModelValidations

      expect(described_class.tariki_required_green_visits)
        .to eq(described_class::DEFAULT_TARIKI_REQUIRED_GREEN_VISITS)
    end

    it 'rejects non-positive and malformed values' do
      expect(param.update(value: '0')).to be(false)
      expect(param.errors[:value]).to include('must be a positive integer')

      expect(param.update(value: '1.5')).to be(false)
      expect(param.errors[:value]).to include('must be a positive integer')
    end
  end

  describe '.tariki_time_window' do
    let(:param) do
      described_class.create!(
        name: described_class::TARIKI_TIME_WINDOW_MONTHS_NAME,
        value: described_class::DEFAULT_TARIKI_TIME_WINDOW_MONTHS.to_s
      )
    end

    it 'returns the configured number of months' do
      param.update!(value: '3')

      expect(described_class.tariki_time_window).to eq(3.months)
    end
  end

  describe 'Tariki status recalculation' do
    let!(:param) do
      described_class.create!(
        name: described_class::TARIKI_REQUIRED_GREEN_VISITS_NAME,
        value: described_class::DEFAULT_TARIKI_REQUIRED_GREEN_VISITS.to_s
      )
    end

    before do
      allow(TarikiStatusRecalculationJob).to receive(:perform_later)
    end

    it 'enqueues recalculation when a Tariki calculation value changes' do
      param.update!(value: '5')

      expect(TarikiStatusRecalculationJob).to have_received(:perform_later).once
    end

    it 'does not enqueue recalculation when a point value changes' do
      point_param = described_class.create!(name: 'green_house_points_user_account', value: '100')

      point_param.update!(value: '150')

      expect(TarikiStatusRecalculationJob).not_to have_received(:perform_later)
    end
  end
end
