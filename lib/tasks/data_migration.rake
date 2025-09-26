# frozen_string_literal: true

namespace :data_migration do
  desc 'Create change_assignment permission and assign to roles'
  task create_change_assignment_permission: :environment do
    permission = Permission.find_or_create_by(name: 'change_assignment', resource: 'users')

    roles = Role.where(name: %w[admin brigadista team_leader])
    roles.each { |role| role.permissions << permission unless role.permissions.include?(permission) }

    puts '✅ Change assignment permission created and assigned!'
  end
end
