class CreateHouses < ActiveRecord::Migration[7.1]
  def change
    create_table :houses do |t|
      t.references :country, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :neighborhood, null: false, foreign_key: true
      t.references :wedge, null: false, foreign_key: true
      t.references :house_block, null: true, foreign_key: true
      t.references :special_place, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.references :user_profile, null: false, foreign_key: true
      t.datetime :discarded_at
      t.string :reference_code
      t.string :house_type
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :notes
      t.string :status
      t.integer :container_count

      t.timestamps
    end
  end
end
