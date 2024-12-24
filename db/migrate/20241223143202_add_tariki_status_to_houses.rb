class AddTarikiStatusToHouses < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :tariki_status, :boolean, default: false
  end
end
