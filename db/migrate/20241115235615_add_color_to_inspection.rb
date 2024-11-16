class AddColorToInspection < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :color, :string
  end
end
