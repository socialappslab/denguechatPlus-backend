class ChangeUserProfileAndTeamInHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :house_blocks, :team_id, true
    change_column_null :house_blocks, :user_profile_id, true
  end
end
