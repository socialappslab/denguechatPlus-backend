class MigrateWaterSourceTypeToJoinTable < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      INSERT INTO inspection_water_source_types (inspection_id, water_source_type_id, created_at, updated_at)
      SELECT id, water_source_type_id, NOW(), NOW()
      FROM inspections
      WHERE water_source_type_id IS NOT NULL
    SQL
  end

end
