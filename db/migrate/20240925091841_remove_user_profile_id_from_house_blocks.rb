class RemoveUserProfileIdFromHouseBlocks < ActiveRecord::Migration[7.1]
  def up
    HouseBlock.where.not(user_profile_id: nil).find_each do |house_block|
      UserProfileHouseBlock.create!(house_block: house_block, user_profile: house_block.brigadist)
    end
  end
end
