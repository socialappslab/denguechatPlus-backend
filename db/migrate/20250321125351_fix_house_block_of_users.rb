class FixHouseBlockOfUsers < ActiveRecord::Migration[7.1]
  def up
    user_accounts_list = UserAccount.joins(:teams).where.not(teams: nil)
    user_accounts_list.each do |user|
      team = user.teams.first
      team_house_blocks = team.wedge&.house_blocks
      current_house_block = user.house_blocks.first
      unless team_house_blocks&.pluck(:id).include?(current_house_block&.id)
        user.house_blocks << team_house_blocks.sample
        user.save!
      end
    end
  end
end
