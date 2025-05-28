# == Schema Information
#
# Table name: house_blocks
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  last_sync_time  :datetime
#  name            :string
#  source          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :integer
#  neighborhood_id :bigint
#
# Indexes
#
#  index_house_blocks_on_neighborhood_id  (neighborhood_id)
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#
class HouseBlock < ApplicationRecord
  has_many :houses, dependent: :nullify
  belongs_to :team, optional: true
  belongs_to :brigadist, class_name: 'UserProfile', foreign_key: 'user_profile_id', optional: true
  has_many :house_block_wedges
  has_many :wedges, through: :house_block_wedges

  has_many :user_profile_house_blocks
  has_many :brigadists, class_name: 'UserProfile', through: :user_profile_house_blocks, source: :user_profile
  belongs_to :neighborhood, optional: true

  default_scope { where(discarded_at: nil) }

end
