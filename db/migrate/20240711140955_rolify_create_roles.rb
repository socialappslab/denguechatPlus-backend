class RolifyCreateRoles < ActiveRecord::Migration[7.1]
  def change

    drop_table :user_accounts_roles
    drop_table :roles

    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:user_accounts_roles, :id => false) do |t|
      t.references :user_account
      t.references :role
    end

    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:user_accounts_roles, [ :user_account_id, :role_id ])

  end
end
