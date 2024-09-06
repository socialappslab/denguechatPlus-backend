class RemoveHasLidToInspections < ActiveRecord::Migration[7.1]
  def change
    remove_column :inspections, :has_lid, if_exists: true
  end
end
