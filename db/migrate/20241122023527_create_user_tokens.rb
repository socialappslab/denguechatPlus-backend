class CreateUserTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :user_tokens do |t|
      t.string :token
      t.datetime :used_at
      t.integer :user_account_id
      t.string :data_type
      t.string :event
      t.string :user_code_recovery_id

      t.timestamps
    end
  end
end
