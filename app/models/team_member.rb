# == Schema Information
#
# Table name: team_members
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_team_members_on_team_id          (team_id)
#  index_team_members_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class TeamMember < ApplicationRecord
  include Discard::Model

  belongs_to :user_profile
  belongs_to :team
end
