# frozen_string_literal: true

namespace :data_migration do
  desc 'Adds visit permission answers to all entries that are missing them'
  task add_visit_permission_answers: :environment do
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    visits = Visit.where.not('jsonb_path_exists(answers, ?)', "$[*].question_#{question.id}_0")

    yes_option, no_option = Option.where(
      name_es: ['Sí, tengo permiso para esta visita', 'No, no me dieron permiso para esta visita']
    )

    visits.each do |visit|
      visit.answers[0] = {
        "question_#{question.id}_0": visit.visit_permission ? yes_option.id : no_option.id,
        **visit.answers[0]
      }
      visit.save!
    end

    puts '✅ Data migration was successful!'
  end

  desc 'Fixes inconsistencies between the visit permission answers and the visit_permission column'
  task fix_visit_permissions: :environment do
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    options = Option.where(question_id: question.id)

    yes_option = options.find { |option| option.name_es == 'Sí, tengo permiso para esta visita' }
    negative_options = options.filter { |option| ['0', nil].include?(option.value) }

    visits = Visit.all

    visits.each do |visit|
      permission_id = visit.answers[0]["question_#{question.id}_0"]

      if permission_id == yes_option.id
        visit.visit_permission = true
      elsif negative_options.include?(permission_id)
        visit.visit_permission = false
      end

      visit.save!
    end

    puts '✅ Data migration was successful!'
  end
end
