# frozen_string_literal: true

class AddTarikiStatusTimeWindowAppConfigParam < ActiveRecord::Migration[7.1]
  class MigrationAppConfigParam < ApplicationRecord
    self.table_name = 'app_config_params'
  end

  def up
    upsert_param(
      name: 'consecutive_green_statuses_for_tariki_house',
      description: 'Number of consecutive green visit days required for a house to reach Tariki status',
      default_value: '4'
    )
    upsert_param(
      name: 'tariki_status_time_window_months',
      description: 'Number of months in which the required green visit days must occur',
      default_value: '2'
    )
  end

  def down
    MigrationAppConfigParam.find_by(name: 'tariki_status_time_window_months')&.destroy!
  end

  private

  def upsert_param(name:, description:, default_value:)
    param = MigrationAppConfigParam.find_or_initialize_by(name:)
    param.value = default_value if param.new_record?
    param.assign_attributes(description:, param_source: 'TarikiStatus', param_type: 'integer')
    param.save!
  end
end
