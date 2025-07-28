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
end
