class AddLanguaguesToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :name_en, :string
    add_column :options, :name_pt, :string
    rename_column :options, :name, :name_es
  end
end
