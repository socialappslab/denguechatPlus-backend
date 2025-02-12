# == Schema Information
#
# Table name: house_block_wedges
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  house_block_id :bigint           not null
#  wedge_id       :bigint           not null
#
# Indexes
#
#  index_house_block_wedges_on_house_block_id               (house_block_id)
#  index_house_block_wedges_on_house_block_id_and_wedge_id  (house_block_id,wedge_id) UNIQUE
#  index_house_block_wedges_on_wedge_id                     (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (house_block_id => house_blocks.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class HouseBlockWedge < ApplicationRecord
  belongs_to :house_block
  belongs_to :wedge
end
