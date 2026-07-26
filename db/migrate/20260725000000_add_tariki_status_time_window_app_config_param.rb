# frozen_string_literal: true

class AddTarikiStatusTimeWindowAppConfigParam < ActiveRecord::Migration[7.1]
  class MigrationAppConfigParam < ApplicationRecord
    self.table_name = 'app_config_params'
  end

  def up
    MigrationAppConfigParam.find_or_create_by!(name: 'tariki_status_time_window_months') do |param|
      param.description = 'Number of months in which the required green visit days must occur'
      param.param_source = 'TarikiStatus'
      param.param_type = 'integer'
      param.value = '2'
    end
  end

  def down
    MigrationAppConfigParam.find_by(name: 'tariki_status_time_window_months')&.destroy!
  end
end
