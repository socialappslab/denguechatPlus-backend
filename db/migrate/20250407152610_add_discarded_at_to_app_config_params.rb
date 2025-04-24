class AddDiscardedAtToAppConfigParams < ActiveRecord::Migration[7.1]
  def change
    add_column :app_config_params, :discarded_at, :datetime
  end
end
