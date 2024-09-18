class AddNewFieldsByLidToInspects < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :lid_type, :string
    add_column :inspections, :lid_type_other, :string
  end
end
