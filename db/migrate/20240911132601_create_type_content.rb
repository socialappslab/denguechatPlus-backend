class CreateTypeContent < ActiveRecord::Migration[7.1]
  def change
    create_table :type_contents do |t|
      t.string :name_es
      t.string :name_en
      t.string :name_pt
      t.datetime :discarded_at

      t.timestamps
    end

    create_table :inspections_type_contents, id: false do |t|
      t.belongs_to :inspection, foreign_key: true
      t.belongs_to :type_content, foreign_key: true
    end
  end
end
