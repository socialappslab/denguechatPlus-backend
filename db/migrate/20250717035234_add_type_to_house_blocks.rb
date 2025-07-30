class AddTypeToHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :house_blocks, :block_type, :string
  end
end
