class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.datetime :discarded_at
      t.boolean :locked, default: false
      t.integer :points, default: 0
      t.datetime :deleted_at
      t.references :organization, null: false, foreign_key: true
      t.references :neighborhood, null: true, foreign_key: true

      t.timestamps
    end
    add_index :teams, %i[name deleted_at], unique: true
  end
end
