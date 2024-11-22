class CreateUserCodeRecovery < ActiveRecord::Migration[7.1]
  def change
    create_table :user_code_recoveries do |t|
      t.integer :user_account_id
      t.string :code
      t.datetime :expired_at
      t.datetime :used_at

      t.timestamps
    end
  end
end
