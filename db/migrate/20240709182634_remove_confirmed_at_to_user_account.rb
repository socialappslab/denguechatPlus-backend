class RemoveConfirmedAtToUserAccount < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_accounts, :confirmed_at
    remove_column :user_accounts, :confirmation_sent_at
  end
end
