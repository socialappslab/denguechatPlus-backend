# == Schema Information
#
# Table name: house_block_houses
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  house_block_id :bigint           not null
#  house_id       :bigint           not null
#
# Indexes
#
#  index_house_block_houses_on_house_block_id               (house_block_id)
#  index_house_block_houses_on_house_id                     (house_id)
#  index_house_block_houses_on_house_id_and_house_block_id  (house_id,house_block_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (house_block_id => house_blocks.id)
#  fk_rails_...  (house_id => houses.id)
#
require 'rails_helper'

RSpec.describe HouseBlockHouse, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
