class RemoveInUseToInspections < ActiveRecord::Migration[7.1]
  def change
    remove_column :inspections, :in_use, :boolean
  end
end
