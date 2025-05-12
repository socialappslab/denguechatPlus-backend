class AddPermissionToChangeUserHouseBlock < ActiveRecord::Migration[7.1]
  def up
    roles = Role.where(name: %w[brigadista facilitador admin])
    permission = Permission.find_or_create_by(name: 'change_house_blocks', resource: 'users')
    roles.each do |role|
      role.permissions << permission unless role.permissions.exists?(permission.id)
    end
  end
end
