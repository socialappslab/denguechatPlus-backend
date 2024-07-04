class CreateStates < ActiveRecord::Migration[7.1]
  def change
    create_table :states do |t|
      t.string :name
      t.datetime :discarded_at
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
    add_index :states, %i[country_id discarded_at], unique: true
    add_index :states, %i[name discarded_at], unique: true
  end
end
