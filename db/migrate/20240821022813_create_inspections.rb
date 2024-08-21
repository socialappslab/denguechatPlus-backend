class CreateInspections < ActiveRecord::Migration[7.1]
  def change
    create_table :inspections do |t|
      t.references :visit, null: false, foreign_key: true
      t.references :breeding_site_type, null: false, foreign_key: true
      t.references :elimination_method_type, null: false, foreign_key: true
      t.references :water_source_type, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :user_accounts }
      t.references :treated_by, null: false, foreign_key: { to_table: :user_accounts }
      t.string :code_reference
      t.boolean :in_use
      t.boolean :has_lid
      t.boolean :has_water
      t.boolean :was_chemically_treated
      t.string :container_test_result
      t.string :tracking_type_required

      t.timestamps
    end
  end
end
