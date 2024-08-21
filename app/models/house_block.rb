# == Schema Information
#
# Table name: house_blocks
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint           not null
#  user_profile_id :bigint           not null
#  wedge_id        :bigint
#
# Indexes
#
#  index_house_blocks_on_team_id          (team_id)
#  index_house_blocks_on_user_profile_id  (user_profile_id)
#  index_house_blocks_on_wedge_id         (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class HouseBlock < ApplicationRecord
  has_many :houses, dependent: :nullify
  belongs_to :team
  belongs_to :brigadist, class_name: 'UserProfile', foreign_key: 'user_profile_id'
  belongs_to :wedge, class_name: 'Wedge', foreign_key: 'wedge_id'
end
