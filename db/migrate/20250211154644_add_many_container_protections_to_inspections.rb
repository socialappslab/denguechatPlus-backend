class AddManyContainerProtectionsToInspections < ActiveRecord::Migration[7.1]
  def up

    execute <<-SQL
      INSERT INTO inspection_container_protections (inspection_id, container_protection_id, created_at, updated_at)
      SELECT id, container_protection_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM inspections
      WHERE container_protection_id IS NOT NULL;
    SQL

    remove_reference :inspections, :container_protection
  end

  def down
    add_reference :inspections, :container_protection, foreign_key: true

    execute <<-SQL
      UPDATE inspections i
      SET container_protection_id = (
        SELECT container_protection_id
        FROM inspection_container_protections
        WHERE inspection_id = i.id
        LIMIT 1
      )
    SQL

    drop_table :inspection_container_protections
  end
end
