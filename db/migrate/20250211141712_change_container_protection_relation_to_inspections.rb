class ChangeContainerProtectionRelationToInspections < ActiveRecord::Migration[7.1]
  def change
    create_table :inspection_container_protections do |t|
      t.references :inspection, foreign_key: true
      t.references :container_protection, foreign_key: true

      t.timestamps
    end
  end
end
