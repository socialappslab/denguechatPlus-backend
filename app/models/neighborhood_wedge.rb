# == Schema Information
#
# Table name: neighborhood_wedges
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  neighborhood_id :bigint           not null
#  wedge_id        :bigint           not null
#
# Indexes
#
#  idx_on_neighborhood_id_wedge_id_discarded_at_29b7affea4  (neighborhood_id,wedge_id,discarded_at) UNIQUE
#  index_neighborhood_wedges_on_neighborhood_id             (neighborhood_id)
#  index_neighborhood_wedges_on_wedge_id                    (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class NeighborhoodWedge < ApplicationRecord
  belongs_to :neighborhood
  belongs_to :wedge

  include Discard::Model
end
