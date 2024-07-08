class AddStatusToUserAccount < ActiveRecord::Migration[7.1]
  def change
    add_column :user_accounts, :status, :boolean, default: false
  end
end
