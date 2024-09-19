class AddInternationalizationToSpecialPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :special_places, :name_es, :string
    add_column :special_places, :name_en, :string
    add_column :special_places, :name_pt, :string
    remove_column :special_places, :name, :string
  end
end
