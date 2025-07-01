class CreateInspectionEliminationMethodTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :inspection_elimination_method_types do |t|
      t.references :inspection, null: false, foreign_key: true
      t.references :elimination_method_type, null: false, foreign_key: true

      t.timestamps
    end

    add_index :inspection_elimination_method_types, %i[inspection_id elimination_method_type_id], unique: true
  end
end
