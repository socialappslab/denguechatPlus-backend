class AddGroupToOptions < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :group_es, :string
    add_column :options, :group_en, :string
    add_column :options, :group_pt, :string
  end
end
