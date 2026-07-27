# frozen_string_literal: true

class AddInspectionCreatePermission < ActiveRecord::Migration[7.1]
  def up
    permission = Permission.find_or_create_by!(name: 'create', resource: 'inspections')

    Role.where(name: Constants::Role::ADMIN).find_each do |role|
      role_permissions = role.permissions
      role_permissions << permission unless role_permissions.exists?(permission.id)
    end
  end
end
