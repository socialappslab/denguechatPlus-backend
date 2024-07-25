class CreateVisitParamVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :visit_param_versions do |t|
      t.string :name
      t.integer :version, default: 1

      t.timestamps
    end
  end
end
