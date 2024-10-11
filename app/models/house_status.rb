# == Schema Information
#
# Table name: house_statuses
#
#  id                      :bigint           not null, primary key
#  date                    :date
#  infected_containers     :integer          default(0)
#  last_visit              :datetime
#  non_infected_containers :integer          default(0)
#  potential_containers    :integer          default(0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  city_id                 :bigint
#  country_id              :bigint
#  house_block_id          :bigint
#  house_id                :bigint
#  neighborhood_id         :bigint
#  team_id                 :bigint
#  wedge_id                :bigint
#
# Indexes
#
#  index_house_statuses_on_city_id          (city_id)
#  index_house_statuses_on_country_id       (country_id)
#  index_house_statuses_on_house_block_id   (house_block_id)
#  index_house_statuses_on_house_id         (house_id)
#  index_house_statuses_on_neighborhood_id  (neighborhood_id)
#  index_house_statuses_on_team_id          (team_id)
#  index_house_statuses_on_wedge_id         (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (house_block_id => house_blocks.id)
#  fk_rails_...  (house_id => houses.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class HouseStatus < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :house_block
  belongs_to :wedge
  belongs_to :neighborhood
  belongs_to :city
  belongs_to :country

end
