# frozen_string_literal: true

namespace :data_migration do
  desc 'Add orphan_houses permission and assign to roles'
  task add_orphan_houses_permission: :environment do
    puts 'Starting migration: add_orphan_houses_permission'
    puts "Environment: #{Rails.env}"

    existing_permission = Permission.find_by(name: 'orphan_houses', resource: 'houses')

    if existing_permission
      puts "WARNING: Permission 'orphan_houses' for resource 'houses' already exists (ID: #{existing_permission.id})"
      puts 'Skipping permission creation.'
    else
      permission = Permission.create!(name: 'orphan_houses', resource: 'houses')
      puts "✓ Created permission ID #{permission.id}: #{permission.name} for #{permission.resource}"
    end

    permission = Permission.find_by(name: 'orphan_houses', resource: 'houses')

    role_names = %w[brigadista team_leader admin]
    roles = Role.where(name: role_names)

    puts "\nAssigning permission to roles:"
    assigned_count = 0

    roles.each do |role|
      if role.permissions.exists?(permission.id)
        puts "  - #{role.name}: permission already assigned"
      else
        role.permissions << permission
        puts "  - #{role.name}: ✓ permission assigned"
        assigned_count += 1
      end
    end

    puts "\n✅ Migration completed successfully"
    puts "Permission 'orphan_houses' for 'houses' is now available to #{assigned_count} role(s)"
  end

  desc 'Add house_blocks permissions and assign to roles'
  task add_house_blocks_permissions: :environment do
    puts 'Starting migration: add_house_blocks_permissions'
    puts "Environment: #{Rails.env}"

    permissions_to_create = [
      { name: 'update', resource: 'house_blocks' },
      { name: 'create', resource: 'house_blocks' }
    ]

    created_permissions = []

    permissions_to_create.each do |permission_data|
      existing_permission = Permission.find_by(name: permission_data[:name], resource: permission_data[:resource])

      if existing_permission
        puts "WARNING: Permission '#{permission_data[:name]}' for resource '#{permission_data[:resource]}' already exists (ID: #{existing_permission.id})"
        created_permissions << existing_permission
      else
        permission = Permission.create!(name: permission_data[:name], resource: permission_data[:resource])
        puts "✓ Created permission ID #{permission.id}: #{permission.name} for #{permission.resource}"
        created_permissions << permission
      end
    end

    role_names = %w[brigadista team_leader admin]
    roles = Role.where(name: role_names)

    puts "\nAssigning permissions to roles:"
    assigned_count = 0

    roles.each do |role|
      created_permissions.each do |permission|
        if role.permissions.exists?(permission.id)
          puts "  - #{role.name}: permission '#{permission.name}' for '#{permission.resource}' already assigned"
        else
          role.permissions << permission
          puts "  - #{role.name}: ✓ permission '#{permission.name}' for '#{permission.resource}' assigned"
          assigned_count += 1
        end
      end
    end

    puts "\n✅ Migration completed successfully"
    puts 'House blocks permissions are now available to roles'
  end

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
