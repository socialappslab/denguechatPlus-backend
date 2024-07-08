# == Schema Information
#
# Table name: team_members
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_team_members_on_team_id          (team_id)
#  index_team_members_on_user_account_id  (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class TeamMember < ApplicationRecord
  include Discard::Model

  delegate :email, :phone, :username, :first_name, :last_name, to: :user_account


  belongs_to :user_account
  belongs_to :team
end
