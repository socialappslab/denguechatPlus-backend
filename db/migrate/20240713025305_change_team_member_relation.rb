class ChangeTeamMemberRelation < ActiveRecord::Migration[7.1]
  def change
    remove_reference :team_members, :user_account, null: false, foreign_key: true
    add_reference :team_members, :user_profile, null: false, foreign_key: true, index: true

  end
end
