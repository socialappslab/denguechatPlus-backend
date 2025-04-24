# == Schema Information
#
# Table name: houses
#
#  id                       :bigint           not null, primary key
#  address                  :string
#  assignment_status        :integer
#  consecutive_green_status :integer          default(0)
#  container_count          :integer
#  discarded_at             :datetime
#  house_type               :string
#  infected_containers      :integer
#  last_sync_time           :datetime
#  last_visit               :datetime
#  latitude                 :float
#  location_status          :string
#  longitude                :float
#  non_infected_containers  :integer
#  notes                    :string
#  potential_containers     :integer
#  reference_code           :string
#  source                   :string
#  status                   :string
#  tariki_status            :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  city_id                  :bigint           not null
#  country_id               :bigint           not null
#  external_id              :string
#  house_block_id           :bigint
#  neighborhood_id          :bigint           not null
#  special_place_id         :bigint
#  state_id                 :bigint           not null
#  team_id                  :bigint
#  user_profile_id          :bigint
#  wedge_id                 :bigint           not null
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
  has_many :visits
  belongs_to :created_by, class_name: 'UserProfile', optional: true, foreign_key: 'user_profile_id'
  belongs_to :special_place, optional: true
  belongs_to :team, optional: true

  enum status: { green: "0", yellow: "1", red: "2" }
  enum assignment_status: { assigned: 1, orphaned: 0}

  after_commit :update_consecutive_green_status


  def is_tariki?(status_on_memory = nil)
    status = status_on_memory || status
    return false unless status == 'green'

    min_consecutive_green = AppConfigParam.find_by(name: 'consecutive_green_statuses_for_tariki_house')&.value.to_i
    return false if min_consecutive_green <= 0

    return true if min_consecutive_green == 1

    statuses = HouseStatus.where(house_id: id).order(created_at: :desc).limit(min_consecutive_green).pluck(:status)

    statuses.all? { |status| status == 'green' }
  end


  def consecutive_green_status_calculation
    limit = AppConfigParam.find_by(name: 'consecutive_green_statuses_for_tariki_house')&.value.to_i
    limit = 4 if limit.zero?

    use_visits = AppConfigParam.find_by(name: 'tariki_point_same_date')&.value.to_i == 1

    statuses = if use_visits
                 visits.sort_by(&:created_at).last(limit).reverse.map(&:status)
               else
                 house_statuses.sort_by(&:created_at).last(limit).reverse.map(&:status)
               end

    statuses.take_while { |s| s.downcase == 'verde' || s.downcase == 'green' }.count
  end


  private

  def update_consecutive_green_status
    statuses = HouseStatus.where(house_id: id).order(created_at: :desc).pluck(:status)
    statuses.unshift(status)
    consecutive_count = 0
    if statuses.first == "green"
      statuses.each do |status|
        if status == "green"
          consecutive_count += 1
        else
          break
        end
      end
    else
      consecutive_count = 0
    end

    update_column(:consecutive_green_status, consecutive_count)
  end
end


