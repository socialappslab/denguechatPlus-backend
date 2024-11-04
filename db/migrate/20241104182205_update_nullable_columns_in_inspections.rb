class UpdateNullableColumnsInInspections < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inspections, :water_source_type_id, true
    change_column_null :inspections, :container_protection_id, true
  end
end
