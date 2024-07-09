class RemoveEmailFromUserAccount < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_accounts, :email
    remove_column :user_accounts, :locked_at
    remove_column :user_profiles, :slug
    add_column :user_profiles, :email, :string
  end
end
