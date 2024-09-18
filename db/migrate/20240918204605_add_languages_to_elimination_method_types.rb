class AddLanguagesToEliminationMethodTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :elimination_method_types, :name_es, :string
    add_column :elimination_method_types, :name_en, :string
    add_column :elimination_method_types, :name_pt, :string
    remove_column :elimination_method_types, :name, :string
  end
end
