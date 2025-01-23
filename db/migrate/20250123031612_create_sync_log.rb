class CreateSyncLog < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_logs do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :processed
      t.integer :errors_quantity

      t.timestamps
    end
  end
end
