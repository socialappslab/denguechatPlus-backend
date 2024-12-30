class CreateNeighborhoodWedges < ActiveRecord::Migration[7.1]
  def change
    create_table :neighborhood_wedges do |t|
      t.references :neighborhood, null: false, foreign_key: true
      t.references :wedge, null: false, foreign_key: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :neighborhood_wedges, %i[neighborhood_id wedge_id discarded_at], unique: true
  end
end
