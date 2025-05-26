class RemoveWaterSourceTypeIdFromInspections < ActiveRecord::Migration[7.1]
  def change
    remove_reference :inspections, :water_source_type, foreign_key: true
  end
end
