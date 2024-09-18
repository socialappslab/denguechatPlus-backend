class AddWaterSourceOtherToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :water_source_other, :string
  end
end
