# frozen_string_literal: true

namespace :data_migration do
  desc 'Set the visit start house and orchard options to positions 1 and 2'
  task set_visit_start_option_positions: :environment do
    question = Question.find_by!(question_text_es: '¿Dónde comienza la visita?')
    house = question.options.find_by!(name_es: 'En la casa')
    orchard = question.options.find_by!(name_es: 'En la huerta')

    if house.position == 1 && orchard.position == 2
      puts 'Visit start options already have positions 1 and 2.'
      next
    end

    Option.transaction do
      house.update!(position: 1) unless house.position == 1
      orchard.update!(position: 2) unless orchard.position == 2
    end

    puts 'Done. En la casa: 1; En la huerta: 2.'
  end
end
