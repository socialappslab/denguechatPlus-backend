class AddNeighborhoodToHouseBlock < ActiveRecord::Migration[7.1]
  def change
    add_reference :house_blocks, :neighborhood, null: true, foreign_key: true, index: true
  end
end
