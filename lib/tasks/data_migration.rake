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
end
