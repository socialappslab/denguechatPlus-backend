# frozen_string_literal: true

namespace :data_migration do
  desc 'Fill the resource_name column for the "¿Me dieron permiso para visitar la casa?" question'
  task fill_resource_name_for_permission_question: :environment do
    puts 'Starting migration: fill_resource_name_for_permission_question'
    puts "Environment: #{Rails.env}"

    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')

    if question.nil?
      puts 'ERROR: Question not found.'
      exit 1
    end

    if question.resource_name.present?
      puts "WARNING: resource_name already set to '#{question.resource_name}'. Skipping."
      exit 0
    end

    puts "Found question ID: #{question.id}"
    puts 'Setting resource_name to "visit_permission"'

    question.update!(resource_name: 'visit_permission')

    puts '✅ Migration completed successfully'
    puts "Question ID #{question.id} now has resource_name: '#{question.resource_name}'"
  end

  desc 'Updates the title of the "¿Encontraste un envase?" question to "¿Encontraste un envase con agua?"'
  task update_question_did_you_find_a_container_title: :environment do
    puts 'Starting migration: update_question_did_you_find_a_container_title'
    puts "Environment: #{Rails.env}"

    questions = Question.where(question_text_es: '¿Encontraste un envase?')

    puts "Found #{questions.count} question(s) to update"

    if questions.empty?
      puts 'No questions found to update'
      exit 0
    end

    # Update each question with new translations
    updated_count = 0
    questions.find_each do |question|
      puts "Updating question ID: #{question.id}"

      question.update!(
        question_text_es: '¿Encontraste un envase con agua?',
        question_text_en: 'Did you find a container with water?',
        question_text_pt: 'Você encontrou um recipiente com água?'
      )

      updated_count += 1
      puts "✓ Updated question ID #{question.id}"
    end

    puts '✅ Migration completed successfully'
    puts "Updated #{updated_count} question(s) with new translations"
  end
end
