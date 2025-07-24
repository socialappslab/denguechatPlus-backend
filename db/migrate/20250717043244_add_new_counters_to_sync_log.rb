class AddNewCountersToSyncLog < ActiveRecord::Migration[7.1]
  def change
    add_column :sync_logs, :house_blocks_created_by_block, :integer, default: 0
    add_column :sync_logs, :house_blocks_updated_by_block, :integer, default: 0
  end
end
