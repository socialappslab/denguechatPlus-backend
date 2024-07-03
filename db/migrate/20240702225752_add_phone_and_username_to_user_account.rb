class AddPhoneAndUsernameToUserAccount < ActiveRecord::Migration[7.1]
  def change
    add_column :user_accounts, :phone, :string, null: true
    add_column :user_accounts, :username, :string, null: true

    add_index :user_accounts, :phone, unique: true
    add_index :user_accounts, :username, unique: true
  end
end
