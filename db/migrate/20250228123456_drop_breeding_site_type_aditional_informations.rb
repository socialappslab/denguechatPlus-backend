# frozen_string_literal: true

class DropBreedingSiteTypeAditionalInformations < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Remove ActiveStorage attachments for the model if table exists
    return unless table_exists?(:breeding_site_type_aditional_informations)

    say_with_time 'Removing ActiveStorage attachments for breeding_site_type_aditional_informations' do
      # Remove rows from active_storage_attachments to avoid orphaned attachments
      execute <<~SQL.squish
        DELETE FROM active_storage_attachments
        WHERE record_type = 'BreedingSiteTypeAditionalInformation';
      SQL
    end

    drop_table :breeding_site_type_aditional_informations
  end

  def down
    create_table :breeding_site_type_aditional_informations do |t|
      t.string :description
      t.boolean :only_image, null: false, default: false
      t.string :title
      t.string :subtitle
      t.references :breeding_site_type, null: false, foreign_key: true

      t.timestamps
    end
    add_index :breeding_site_type_aditional_informations, :breeding_site_type_id,
              name: 'idx_on_breeding_site_type_id_a588ef2362'
  end
end
