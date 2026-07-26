# frozen_string_literal: true

namespace :data_migration do
  desc 'Recalculate persisted house Tariki statuses with the current backend rule'
  task recalculate_tariki_statuses: :environment do
    puts 'Recalculating house Tariki statuses...'

    recalculated_count = Services::TarikiStatusRecalculator.call

    puts "Done. Updated #{recalculated_count} houses."
  end
end
