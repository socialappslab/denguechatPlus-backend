class AddExternalIdToHouseBlockCunasNeighborhood < ActiveRecord::Migration[7.1]
  def change
    # we don't have control about the external datatype, this is because we prefer use in the house case string as external_id data type
    add_column :houses, :external_id, :string
    add_column :houses, :assignment_status, :integer
    add_column :houses, :source, :string
    add_column :wedges, :external_id, :integer
    add_column :wedges, :source, :string
    add_column :neighborhoods, :external_id, :integer
    add_column :neighborhoods, :source, :string
    add_column :house_blocks, :external_id, :integer
    add_column :house_blocks, :source, :string
  end
end
