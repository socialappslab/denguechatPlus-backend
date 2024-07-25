class CreateContainerTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :container_types do |t|
      t.string :name
      t.references :breeding_site_type, null: false, foreign_key: true
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
