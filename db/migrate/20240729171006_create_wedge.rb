class CreateWedge < ActiveRecord::Migration[7.1]
  def change
    create_table :wedges do |t|
      t.string :name
      t.datetime :discarded_at
      t.references :neighborhood, index: true, foreign_key: true, null: false

      t.timestamps
    end
    add_index :wedges, %i[neighborhood_id discarded_at], unique: true
  end
end
