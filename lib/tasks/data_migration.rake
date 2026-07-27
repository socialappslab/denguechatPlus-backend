# frozen_string_literal: true

namespace :data_migration do
  desc 'Recalculate persisted Tariki house statuses with the current backend rule'
  task recalculate_tariki_statuses: :environment do
    puts 'Recalculating house Tariki statuses...'

    recalculated_count = Services::TarikiStatusRecalculator.call

    puts "Done. Updated #{recalculated_count} houses."
  end

  desc 'Remove the legacy same-day Tariki calculation app config param'
  task remove_tariki_calculation_app_config_params: :environment do
    removed_count = AppConfigParam.where(name: 'tariki_point_same_date').delete_all

    puts "Done. Removed #{removed_count} Tariki calculation app config params."
  end
end
