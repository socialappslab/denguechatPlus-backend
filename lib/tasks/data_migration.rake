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

  desc 'Add new options to the "¿Qué información compartiste?" question'
  task add_information_shared_options: :environment do
    puts 'Starting migration: add_information_shared_options'
    puts "Environment: #{Rails.env}"

    question = Question.find_by(question_text_es: '¿Qué información compartiste?')

    if question.nil?
      puts 'Question "¿Qué información compartiste?" not found.'
      exit 0
    end

    puts "Found question ID: #{question.id}"
    puts "Question: #{question.question_text_es}"

    # Find the "Otro tema importante" option that should always be last
    another_topic_option = question.options.find_by(name_es: 'Otro tema importante')

    if another_topic_option
      puts "Found 'Otro tema importante' option at position #{another_topic_option.position}"
      # Insert new options before "Otro tema importante"
      insert_position = another_topic_option.position
    else
      puts "No 'Otro tema importante' option found, adding to end"
      insert_position = (question.options.maximum(:position) || 0) + 1
    end

    # New options to add
    new_options = [
      {
        name_es: 'Explicación sobre cómo manejar los envases',
        name_en: 'Explanation on how to handle containers',
        name_pt: 'Explicação sobre como lidar com os recipientes',
        next: -1,
        position: insert_position
      },
      {
        name_es: 'Explicación sobre la enfermedad del dengue',
        name_en: 'Explanation about dengue disease',
        name_pt: 'Explicação sobre a doença da dengue',
        next: -1,
        position: insert_position + 1
      }
    ]

    # Check if options already exist
    existing_options = question.options.where(name_es: new_options.pluck(:name_es))
    if existing_options.any?
      puts 'WARNING: Some options already exist:'
      existing_options.each do |option|
        puts "  - #{option.name_es} (ID: #{option.id})"
      end
      puts 'Skipping migration.'
      exit 0
    end

    # Create new options
    created_count = 0
    new_options.each do |option_data|
      option = question.options.create!(
        name_es: option_data[:name_es],
        name_en: option_data[:name_en],
        name_pt: option_data[:name_pt],
        next: option_data[:next],
        position: option_data[:position]
      )

      created_count += 1
      puts "✓ Created option ID #{option.id}: #{option.name_es}"
    end

    # Move "Otro tema importante" to the end if it exists
    if another_topic_option
      new_last_position = insert_position + new_options.length
      another_topic_option.update!(position: new_last_position)
      puts "✓ Moved 'Otro tema importante' to position #{new_last_position}"
    end

    puts '✅ Migration completed successfully'
    puts "Created #{created_count} new option(s) for question ID #{question.id}"
  end

  desc 'Replace "contenedor" and "recipiente/envase" with "envase" in elimination_method_types name_es column'
  task update_elimination_method_types_terminology: :environment do
    puts 'Starting migration: update_elimination_method_types_terminology'
    puts "Environment: #{Rails.env}"

    # Find all records containing "contenedor" or "recipiente/envase" in name_es
    records_to_update = EliminationMethodType.where(
      'name_es ILIKE ? OR name_es ILIKE ?',
      '%contenedor%',
      '%recipiente%'
    )

    puts "Found #{records_to_update.count} record(s) to update"

    if records_to_update.empty?
      puts 'No records found to update'
      exit 0
    end

    # Show records that will be updated
    puts "\nRecords that will be updated:"
    records_to_update.each do |record|
      puts "  ID #{record.id}: '#{record.name_es}'"
    end

    updated_count = 0
    records_to_update.find_each do |record|
      original_name = record.name_es

      # Replace "contenedor" with "envase"
      new_name = original_name.gsub(/contenedor/i, 'envase')

      # Replace "recipiente/envase" with "envase"
      new_name = new_name.gsub(/recipiente\/envase/i, 'envase')

      # Also replace standalone "recipiente" with "envase"
      new_name = new_name.gsub(/recipiente(?!\/)/i, 'envase')

      if new_name == original_name
        puts "Record ID #{record.id} already has correct terminology, skipping"
      else
        puts "Updating record ID #{record.id}:"
        puts "  From: '#{original_name}'"
        puts "  To:   '#{new_name}'"

        record.update!(name_es: new_name)
        updated_count += 1
        puts '  ✓ Updated successfully'
      end
    end

    puts "\n✅ Migration completed successfully"
    puts "Updated #{updated_count} elimination method type(s) with new terminology"
  end
end
