# == Schema Information
#
# Table name: neighborhoods
#
#  id             :bigint           not null, primary key
#  discarded_at   :datetime
#  last_sync_time :datetime
#  name           :string
#  source         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  city_id        :bigint           not null
#  country_id     :bigint           not null
#  external_id    :integer
#  state_id       :bigint           not null
#  wedge_id       :bigint
#
# Indexes
#
#  idx_on_country_id_state_id_city_id_discarded_at_d4d773c91a  (country_id,state_id,city_id,discarded_at) UNIQUE
#  index_neighborhoods_on_city_id                              (city_id)
#  index_neighborhoods_on_country_id                           (country_id)
#  index_neighborhoods_on_name_and_discarded_at                (name,discarded_at) UNIQUE
#  index_neighborhoods_on_state_id                             (state_id)
#  index_neighborhoods_on_wedge_id                             (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (state_id => states.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class Neighborhood < ApplicationRecord
  include Discard::Model

  belongs_to :city
  belongs_to :state
  belongs_to :country
  has_many :user_profiles
  has_many :neighborhood_wedges, dependent: :destroy
  has_many :wedges, through: :neighborhood_wedges
end
