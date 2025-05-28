class RenameContainerTypeAndBreedingSiteType < ActiveRecord::Migration[7.1]
  def change
    remove_index :container_types, name: "index_container_types_on_breeding_site_type_id"
    remove_foreign_key :inspections, column: :breeding_site_type_id
    remove_column :container_types, :breeding_site_type_id
    rename_table :container_types, :temporary_container_types
    rename_table :breeding_site_types, :container_types
    rename_table :temporary_container_types, :breeding_site_types
    drop_table :container_types
    add_foreign_key :inspections, :breeding_site_types, column: :breeding_site_type_id
  end
end
