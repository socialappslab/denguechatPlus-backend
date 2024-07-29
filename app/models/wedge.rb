# == Schema Information
#
# Table name: wedges
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  neighborhood_id :bigint           not null
#
# Indexes
#
#  index_wedges_on_neighborhood_id                   (neighborhood_id)
#  index_wedges_on_neighborhood_id_and_discarded_at  (neighborhood_id,discarded_at) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#
class Wedge < ApplicationRecord
  include Discard::Model

  belongs_to :sector, class_name: 'Neighborhood', foreign_key: 'neighborhood_id', optional: true

end
