# frozen_string_literal: true

namespace :data_migration do
  desc "Reorders the options of the question about the container content to it's proper order"
  task fix_container_content_options_order: :environment do
    options = Question.find_by(question_text_es: 'En este envase hay..').options

    position_by_name = {
      'Huevos' => 1,
      'Larvas' => 2,
      'Pupas' => 3,
      'Nada' => 4,
      'No pude revisar el envase' => 5
    }

    Option.transaction do
      options.each do |option|
        new_position = position_by_name[option.name_es]
        next unless new_position

        option.update!(position: new_position)
      end
    end
  end
end
