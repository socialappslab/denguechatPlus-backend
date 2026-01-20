# frozen_string_literal: true

namespace :data_migration do
  desc 'Add wedges stats permission to brigadista, team_leader, and admin roles'
  task add_wedges_stats_permission: :environment do
    roles = Role.where(name: %w[brigadista team_leader admin])
    permission = Permission.find_or_create_by(name: 'stats', resource: 'wedges')

    roles.find_each do |role|
      role.permissions << permission unless role.permissions.exists?(permission.id)
    end

    puts "✅ Added wedges stats permission to #{roles.count} roles."
  end
end
