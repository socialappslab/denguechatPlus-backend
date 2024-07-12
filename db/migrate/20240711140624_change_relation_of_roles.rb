class ChangeRelationOfRoles < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_profiles_roles
  end
end
