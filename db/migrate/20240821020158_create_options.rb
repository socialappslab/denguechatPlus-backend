class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :name
      t.boolean :required, default: false
      t.boolean :text_area, default: false
      t.integer :next
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
