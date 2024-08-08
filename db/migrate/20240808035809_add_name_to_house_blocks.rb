class AddNameToHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :house_blocks, :name, :string
  end
end
