# == Schema Information
#
# Table name: house_blocks
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_house_blocks_on_team_id          (team_id)
#  index_house_blocks_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class HouseBlock < ApplicationRecord
  has_many :houses, dependent: :nullify
  belongs_to :team
  belongs_to :created_by, class_name: 'UserProfile'
end
