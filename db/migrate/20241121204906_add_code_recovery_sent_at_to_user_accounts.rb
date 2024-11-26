class AddCodeRecoverySentAtToUserAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :user_accounts, :code_recovery_sent_at, :datetime
  end
end
