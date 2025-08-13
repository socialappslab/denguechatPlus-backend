# frozen_string_literal: true

namespace :data_migration do
  desc 'Migrate "Pozos" option to "Tanques" and remove the old option'
  task migrate_pozos_to_tanques: :environment do
    puts 'Starting migration: migrate_pozos_to_tanques'
    puts "Environment: #{Rails.env}"

    # Find the question
    question = Question.find_by(question_text_es: '¿Qué tipo de envase encontraste?')

    unless question
      puts "ERROR: Question with text '¿Qué tipo de envase encontraste?' not found"
      return
    end

    puts "✓ Found question: #{question.question_text_es} (ID: #{question.id})"

    # Find the "Pozos" option
    pozos_option = question.options.find_by(name_es: 'Pozos')

    unless pozos_option
      puts "ERROR: Option 'Pozos' not found for this question"
      return
    end

    puts "✓ Found 'Pozos' option (ID: #{pozos_option.id}, resource_id: #{pozos_option.resource_id})"

    # Find the "Tanques" option
    tanques_option = question.options.find_by(name_es: 'Tanques')

    unless tanques_option
      puts "ERROR: Option 'Tanques' not found for this question"
      return
    end

    puts "✓ Found 'Tanques' option (ID: #{tanques_option.id}, resource_id: #{tanques_option.resource_id})"

    # Find the breeding site types
    pozos_bst = BreedingSiteType.find_by(name: 'Pozos')
    tanques_bst = BreedingSiteType.find_by(name: 'Tanques')

    unless pozos_bst
      puts "ERROR: BreedingSiteType 'Pozos' not found"
      return
    end

    unless tanques_bst
      puts "ERROR: BreedingSiteType 'Tanques' not found"
      return
    end

    puts "✓ Found BreedingSiteType 'Pozos' (ID: #{pozos_bst.id})"
    puts "✓ Found BreedingSiteType 'Tanques' (ID: #{tanques_bst.id})"

    # Count inspections that will be migrated
    inspections_to_migrate = Inspection.where(breeding_site_type_id: pozos_bst.id)
    inspection_count = inspections_to_migrate.count

    # Check for additional information records
    additional_info_count = pozos_bst.additional_information.count

    puts "\n📊 Migration Summary:"
    puts "  - Inspections to migrate: #{inspection_count}"
    puts "  - Additional information records: #{additional_info_count}"
    puts "  - From BreedingSiteType: 'Pozos' (ID: #{pozos_bst.id})"
    puts "  - To BreedingSiteType: 'Tanques' (ID: #{tanques_bst.id})"

    if inspection_count.zero?
      puts "\n⚠️  No inspections found to migrate"
    else
      # Migrate inspections
      puts "\n🔄 Migrating inspections..."
      updated_count = inspections_to_migrate.update_all(breeding_site_type_id: tanques_bst.id)
      puts "✓ Successfully migrated #{updated_count} inspections"
    end

    # Handle additional information records
    if additional_info_count.positive?
      puts "\n🔄 Migrating additional information records..."
      pozos_bst.additional_information.update_all(breeding_site_type_id: tanques_bst.id)
      puts "✓ Successfully migrated #{additional_info_count} additional information records"
    end

    # Safety check: verify no other references to pozos_bst
    remaining_inspections = Inspection.where(breeding_site_type_id: pozos_bst.id).count
    remaining_additional_info = pozos_bst.additional_information.count

    if remaining_inspections.positive? || remaining_additional_info.positive?
      puts "\n❌ ERROR: Still found references to 'Pozos' breeding site type:"
      puts "  - Remaining inspections: #{remaining_inspections}"
      puts "  - Remaining additional info: #{remaining_additional_info}"
      puts 'Migration aborted for safety.'
      return
    end

    puts "\n✅ Safety check passed - no remaining references to 'Pozos' breeding site type"

    # Remove the "Pozos" option
    puts "\n🗑️  Removing 'Pozos' option..."
    pozos_option.destroy!
    puts "✓ Removed 'Pozos' option (ID: #{pozos_option.id})"

    # Remove the "Pozos" breeding site type
    puts "\n🗑️  Removing 'Pozos' breeding site type..."
    pozos_bst.destroy!
    puts "✓ Removed 'Pozos' breeding site type (ID: #{pozos_bst.id})"

    puts "\n✅ Migration completed successfully!"
    puts "  - #{inspection_count} inspections migrated from 'Pozos' to 'Tanques'"
    puts "  - #{additional_info_count} additional information records migrated"
    puts "  - 'Pozos' option and breeding site type removed"
  end
end
