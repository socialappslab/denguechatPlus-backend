class ChangeStatusAndLockedToUserAccount < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_accounts, :status
    remove_column :user_accounts, :locked

    add_column :user_accounts, :status, :integer, default: 0
  end
end
