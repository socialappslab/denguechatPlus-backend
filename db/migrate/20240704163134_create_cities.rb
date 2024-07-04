class CreateCities < ActiveRecord::Migration[7.1]
  def change
    create_table :cities do |t|
      t.string :name
      t.datetime :discarded_at
      t.references :state, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end

    add_index :cities, %i[state_id country_id discarded_at], unique: true
    add_index :cities, %i[name discarded_at], unique: true
  end
end
