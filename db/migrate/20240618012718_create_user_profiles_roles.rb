# frozen_string_literal: true

class CreateUserProfilesRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_profiles_roles do |t|
      t.references :user_profile, foreign_key: true, null: false, index: true
      t.references :role, foreign_key: true, null: false, index: true

      t.timestamps
    end
  end
end
