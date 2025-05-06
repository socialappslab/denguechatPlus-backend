class CreateInspectionWaterSourceTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :inspection_water_source_types do |t|
      t.references :inspection, null: false, foreign_key: true
      t.references :water_source_type, null: false, foreign_key: true

      t.timestamps
    end

    add_index :inspection_water_source_types, %i[inspection_id water_source_type_id], unique: true
  end
end
