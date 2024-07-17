# == Schema Information
#
# Table name: roles_permissions
#
#  id            :bigint           not null, primary key
#  permission_id :bigint           not null
#  role_id       :bigint           not null
#
# Indexes
#
#  index_roles_permissions_on_permission_id              (permission_id)
#  index_roles_permissions_on_permission_id_and_role_id  (permission_id,role_id) UNIQUE
#  index_roles_permissions_on_role_id                    (role_id)
#
class RolePermission < ApplicationRecord
  self.table_name = 'roles_permissions'
  belongs_to :permission
  belongs_to :role

  default_scope { order(role_id: :desc) }
end
