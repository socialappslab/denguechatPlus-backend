# frozen_string_literal: true

namespace :data_migration do
  desc 'Recalculate persisted house Tariki statuses with the current backend rule'
  task recalculate_tariki_statuses: :environment do
    puts 'Recalculating house Tariki statuses...'

    recalculated_count = 0
    House.find_each do |house|
      latest_visit = Visit.where(house_id: house.id).order(visited_at: :desc, created_at: :desc).first
      next unless latest_visit

      tariki_status = house.tariki?(latest_visit.status, reference_time: latest_visit.visited_at)
      next if house.tariki_status == tariki_status

      house.update!(tariki_status:)
      recalculated_count += 1
    end

    puts "Done. Updated #{recalculated_count} houses."
  end

  desc 'Remove legacy Tariki calculation app config params'
  task remove_tariki_calculation_app_config_params: :environment do
    names = %w[
      consecutive_green_statuses_for_tariki_house
      tariki_point_same_date
    ]

    removed_count = AppConfigParam.where(name: names).delete_all

    puts "Done. Removed #{removed_count} Tariki calculation app config params."
  end
end
