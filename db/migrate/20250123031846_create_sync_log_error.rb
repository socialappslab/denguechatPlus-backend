class CreateSyncLogError < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_log_errors do |t|
      t.string :item_id
      t.string :message
      t.references :sync_log, null: false, foreign_key: true

      t.timestamps
    end
  end
end
