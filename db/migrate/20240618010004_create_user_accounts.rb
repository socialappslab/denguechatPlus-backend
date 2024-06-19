# frozen_string_literal: true

class CreateUserAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_accounts do |t|
      t.string :email
      t.string :password_digest
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.boolean :locked, default: false, null: false
      t.datetime :locked_at
      t.datetime :discarded_at
      t.references :user_profile, foreign_key: true, index: true

      t.index :email, unique: true
      t.index :discarded_at

      t.timestamps
    end
  end
end
