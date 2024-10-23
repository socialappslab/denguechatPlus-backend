class AddNotesToQuestion < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :notes_es, :string
    add_column :questions, :notes_en, :string
    add_column :questions, :notes_pt, :string
  end
end
