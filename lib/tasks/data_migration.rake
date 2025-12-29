# frozen_string_literal: true

namespace :data_migration do
  desc 'Backfill visit_permission_option_id from answers column'
  task backfill_visit_permission: :environment do
    visit_permission_question = Question.find_by!(question_text_es: '¿Me dieron permiso para visitar la casa?')
    question_id = visit_permission_question.id
    valid_option_ids = visit_permission_question.options.pluck(:id)

    updated_count = 0
    skipped_count = 0
    error_count = 0

    Visit.where.not(answers: nil).find_each do |visit|
      answers = visit.answers
      next if answers.blank? || !answers.is_a?(Array)

      key_pattern = /^question_#{question_id}_\d+$/
      option_id = nil
      found_container_index = nil
      found_key = nil

      answers.each_with_index do |container, index|
        next unless container.is_a?(Hash)

        container.each do |key, value|
          next unless key.to_s.match?(key_pattern)

          option_id = value
          found_container_index = index
          found_key = key
          break
        end
        break if option_id
      end

      if option_id.nil?
        skipped_count += 1
        next
      end

      unless valid_option_ids.include?(option_id)
        puts "⚠️  Visit #{visit.id}: Invalid option_id #{option_id}"
        error_count += 1
        next
      end

      answers[found_container_index].delete(found_key.to_s)
      answers[found_container_index].delete(found_key.to_sym)

      answers.reject! { |container| container.is_a?(Hash) && container.empty? }

      visit.update_columns(
        visit_permission_option_id: option_id,
        answers: answers.presence || []
      )

      updated_count += 1
      print '.' if (updated_count % 100).zero?
    end

    puts "\n✅ Backfill complete!"
    puts "   Updated: #{updated_count}"
    puts "   Skipped (no permission answer): #{skipped_count}"
    puts "   Errors: #{error_count}"
  end
end
