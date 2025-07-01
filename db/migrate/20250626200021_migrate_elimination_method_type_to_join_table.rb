class MigrateEliminationMethodTypeToJoinTable < ActiveRecord::Migration[7.1]
  def change
    execute <<-SQL
      INSERT INTO inspection_elimination_method_types (inspection_id, elimination_method_type_id, created_at, updated_at)
      SELECT id, elimination_method_type_id, NOW(), NOW()
      FROM inspections
      WHERE elimination_method_type_id IS NOT NULL
    SQL
  end
end
