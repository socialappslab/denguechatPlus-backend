class DeleteOldRelationsToHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    remove_reference :house_blocks, :user_profile, foreign_key: true if column_exists?(:house_blocks, :user_profile_id)
    return unless column_exists?(:house_blocks, :team_id)

    remove_reference :house_blocks, :team, foreign_key: true
  end
end
