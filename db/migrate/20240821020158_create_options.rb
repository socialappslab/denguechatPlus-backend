class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :name
      t.boolean :required
      t.boolean :text_area
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
