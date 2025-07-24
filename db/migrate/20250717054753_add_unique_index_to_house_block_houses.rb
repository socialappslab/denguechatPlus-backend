class AddUniqueIndexToHouseBlockHouses < ActiveRecord::Migration[7.1]
  def change
    add_index :house_block_houses, [:house_id, :house_block_id], unique: true
  end
end
