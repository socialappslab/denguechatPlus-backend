# frozen_string_literal: true

class AddAvatarPermissions < ActiveRecord::Migration[7.1]
  def up
    permissions = [
      Permission.find_or_create_by!(name: 'index', resource: 'avatars'),
      Permission.find_or_create_by!(name: 'change_avatar', resource: 'users')
    ]

    Role.find_each do |role|
      role_permissions = role.permissions
      permissions.each do |permission|
        role_permissions << permission unless role_permissions.exists?(permission.id)
      end
    end
  end
end
