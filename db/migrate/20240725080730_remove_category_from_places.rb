class RemoveCategoryFromPlaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :places, :category
  end
end
