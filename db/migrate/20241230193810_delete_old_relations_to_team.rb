class DeleteOldRelationsToTeam < ActiveRecord::Migration[7.1]
  def change
    remove_index :teams, :leader_id if index_exists?(:teams, :leader_id)

    return unless column_exists?(:teams, :leader_id)

    remove_column :teams, :leader_id
  end
end
