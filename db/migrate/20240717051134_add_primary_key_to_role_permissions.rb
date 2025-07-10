# frozen_string_literal: true

class AddPrimaryKeyToRolePermissions < ActiveRecord::Migration[7.1]
  def change
    add_column :roles_permissions, :id, :primary_key
  end

  def up
    reset_pk_sequence!(RolePermission.table_name)
  end

  def reset_pk_sequence!(_table_name)
    result = ActiveRecord::Base.connection.execute('SELECT MAX("id") FROM roles_permissions')
    max_id = result.first['max'].to_i
    ActiveRecord::Base.connection.reset_pk_sequence!('roles_permissions', 'id', max_id + 1)
  end
end
