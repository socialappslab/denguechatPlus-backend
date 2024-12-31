class DeleteOldRelationsToTeam < ActiveRecord::Migration[7.1]
  def change
    if index_exists?(:teams, :leader_id)
      remove_index :teams, :leader_id
    end

    if column_exists?(:teams, :leader_id)
      remove_column :teams, :leader_id
    end
  end
end
