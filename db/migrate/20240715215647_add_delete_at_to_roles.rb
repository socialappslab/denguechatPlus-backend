class AddDeleteAtToRoles < ActiveRecord::Migration[7.1]
  def change
    add_column :roles, :discarded_at, :datetime
  end
end
