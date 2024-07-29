class DropTeamMembers < ActiveRecord::Migration[7.1]
  def change
    drop_table :team_members
  end
end
