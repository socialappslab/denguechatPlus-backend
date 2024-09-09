class AddLanguaguesToQuestion < ActiveRecord::Migration[7.1]
  def change
    rename_column :questions, :description, :description_es
    add_column :questions, :description_en, :string
    add_column :questions, :description_pt, :string
    rename_column :questions, :question_text, :question_text_es
    add_column :questions, :question_text_en, :string
    add_column :questions, :question_text_pt, :string
  end
end
