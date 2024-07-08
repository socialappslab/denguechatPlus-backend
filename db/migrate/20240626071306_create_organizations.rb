# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :organizations, :name, unique: true
    add_index :organizations, :discarded_at
  end
end
