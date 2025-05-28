class AddToQuestionsHierarchyChanges < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :parent_id, :integer
    add_column :questions, :visible, :boolean, default: true, null: false
    add_index :questions, :parent_id
  end
end
