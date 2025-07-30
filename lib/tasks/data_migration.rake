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
end
