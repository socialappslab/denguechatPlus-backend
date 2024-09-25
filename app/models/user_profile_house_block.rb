# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profile_house_blocks
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  house_block_id  :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_profile_house_blocks_on_house_block_id   (house_block_id)
#  index_user_profile_house_blocks_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (house_block_id => house_blocks.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class UserProfileHouseBlock < ApplicationRecord
  belongs_to :user_profile
  belongs_to :house_block
end
