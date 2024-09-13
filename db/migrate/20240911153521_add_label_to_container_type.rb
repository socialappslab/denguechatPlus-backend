class AddLabelToContainerType < ActiveRecord::Migration[7.1]
  def change
    add_column :container_types, :container_type, :string
  end
end
