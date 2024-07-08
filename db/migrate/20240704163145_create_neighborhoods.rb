class CreateNeighborhoods < ActiveRecord::Migration[7.1]
  def change
    create_table :neighborhoods do |t|
      t.string :name
      t.datetime :discarded_at
      t.references :country, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end

    add_index :neighborhoods, %i[country_id state_id city_id discarded_at], unique: true
    add_index :neighborhoods, %i[name discarded_at], unique: true
  end
end
