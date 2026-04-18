# frozen_string_literal: true

namespace :data_migration do
  desc 'Renames the label of the option "Otro (tratamiento manual)" to just "Otro"'
  task rename_option: :environment do
    Option.find_by!(name_es: 'Otro (tratamiento manual)')
          .update!(name_es: 'Otro', name_en: 'Other', name_pt: 'Outro')
  end
end
