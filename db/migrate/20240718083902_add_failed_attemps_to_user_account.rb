class AddFailedAttempsToUserAccount < ActiveRecord::Migration[7.1]
  def change
    add_column :user_accounts, :failed_attempts, :integer, default: 0
  end
end
