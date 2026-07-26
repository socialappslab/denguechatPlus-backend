# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::GetLastParams::Queries::Index do
  describe '.call' do
    before do
      %w[
        consecutive_green_statuses_for_tariki_house
        green_house_points_team
        green_house_points_user_account
        tariki_point_same_date
        tariki_status_time_window_months
      ].each { |name| AppConfigParam.create!(name:, value: '1') }
    end

    it 'preserves the app configuration resource expected by mobile' do
      app_config = described_class.call(nil).find { |resource| resource.resource_name == 'AppConfigParam' }
      names = app_config.resource_data.map { |param| param['name'] }

      expect(names).to include(
        'consecutive_green_statuses_for_tariki_house',
        'green_house_points_team',
        'green_house_points_user_account',
        'tariki_point_same_date'
      )
      expect(names).not_to include('tariki_status_time_window_months')
    end
  end
end
