class AddLastSyncToHouseNeighborhoodWedgeHouseBlock < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :last_sync_time, :datetime
    add_column :neighborhoods, :last_sync_time, :datetime
    add_column :wedges, :last_sync_time, :datetime
    add_column :house_blocks, :last_sync_time, :datetime
  end
end
