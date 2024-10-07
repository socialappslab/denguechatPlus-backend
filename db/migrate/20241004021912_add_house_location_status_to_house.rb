class AddHouseLocationStatusToHouse < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :location_status, :string
  end
end
