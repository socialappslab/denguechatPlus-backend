# == Schema Information
#
# Table name: house_blocks
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint
#  user_profile_id :bigint
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
  belongs_to :team, optional: true
  belongs_to :brigadist, class_name: 'UserProfile', foreign_key: 'user_profile_id', optional: true
  belongs_to :wedge, class_name: 'Wedge', foreign_key: 'wedge_id'

  has_many :user_profile_house_blocks
  has_many :brigadists, class_name: 'UserProfile', through: :user_profile_house_blocks, source: :user_profile
end
