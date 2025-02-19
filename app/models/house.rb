# == Schema Information
#
# Table name: houses
#
#  id                      :bigint           not null, primary key
#  address                 :string
#  assignment_status       :integer
#  container_count         :integer
#  discarded_at            :datetime
#  house_type              :string
#  infected_containers     :integer
#  last_sync_time          :datetime
#  last_visit              :datetime
#  latitude                :float
#  location_status         :string
#  longitude               :float
#  non_infected_containers :integer
#  notes                   :string
#  potential_containers    :integer
#  reference_code          :string
#  source                  :string
#  status                  :string
#  tariki_status           :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  city_id                 :bigint           not null
#  country_id              :bigint           not null
#  external_id             :string
#  house_block_id          :bigint
#  neighborhood_id         :bigint           not null
#  special_place_id        :bigint
#  state_id                :bigint           not null
#  team_id                 :bigint
#  user_profile_id         :bigint
#  wedge_id                :bigint           not null
#
# Indexes
#
#  index_houses_on_city_id           (city_id)
#  index_houses_on_country_id        (country_id)
#  index_houses_on_house_block_id    (house_block_id)
#  index_houses_on_neighborhood_id   (neighborhood_id)
#  index_houses_on_reference_code    (reference_code) UNIQUE
#  index_houses_on_special_place_id  (special_place_id)
#  index_houses_on_state_id          (state_id)
#  index_houses_on_team_id           (team_id)
#  index_houses_on_user_profile_id   (user_profile_id)
#  index_houses_on_wedge_id          (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (house_block_id => house_blocks.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (special_place_id => special_places.id)
#  fk_rails_...  (state_id => states.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class House < ApplicationRecord
  belongs_to :country
  belongs_to :state
  belongs_to :city
  belongs_to :neighborhood
  belongs_to :wedge
  belongs_to :house_block, optional: true
  has_many :house_statuses
  belongs_to :created_by, class_name: 'UserProfile', optional: true, foreign_key: 'user_profile_id'
  belongs_to :special_place, optional: true
  belongs_to :team, optional: true

  enum status: { green: "0", yellow: "1", red: "2" }
  enum assignment_status: { assigned: 1, orphaned: 0}


  def is_tariki?(new_status = status)
    last_statuses = HouseStatus.where(house_id: id).last(3).pluck(:status)
    return false if last_statuses.count < 3
    return true if last_statuses == %w[green green green] && new_status == 'green'

    false
  end

end
