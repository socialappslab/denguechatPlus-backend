class AddLocationToInspection < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :location, :string
  end
end
