class CreateContainerProtections < ActiveRecord::Migration[7.1]
  def change
    create_table :container_protections do |t|
      t.string :name_es
      t.string :name_en
      t.string :name_pt
      t.string :color
      t.datetime :discarded_at

      t.timestamps
    end

    add_reference :inspections, :container_protection, foreign_key: true, null: true
    add_column :inspections, :other_protection, :string
  end
end
