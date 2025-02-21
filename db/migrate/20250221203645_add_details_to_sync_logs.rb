class AddDetailsToSyncLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :sync_logs, :houses_updated, :integer
    add_column :sync_logs, :houses_created, :integer

    add_column :sync_logs, :house_blocks_updated, :integer
    add_column :sync_logs, :house_blocks_created, :integer

    add_column :sync_logs, :wedges_updated, :integer
    add_column :sync_logs, :wedges_created, :integer

    add_column :sync_logs, :sectors_updated, :integer
    add_column :sync_logs, :sectors_created, :integer
  end
end
