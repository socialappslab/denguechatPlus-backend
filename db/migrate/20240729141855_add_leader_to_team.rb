class AddLeaderToTeam < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :leader, foreign_key: { to_table: :user_profiles }
  end
end
