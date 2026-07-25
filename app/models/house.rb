# frozen_string_literal: true

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
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (special_place_id => special_places.id)
#  fk_rails_...  (state_id => states.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class House < ApplicationRecord
  include HasRiskColor

  belongs_to :country
  belongs_to :state
  belongs_to :city
  belongs_to :neighborhood
  belongs_to :wedge
  has_many :house_block_houses
  has_many :house_blocks, through: :house_block_houses

  has_many :house_statuses
  has_many :visits
  belongs_to :created_by, class_name: 'UserProfile', optional: true, foreign_key: 'user_profile_id'
  belongs_to :special_place, optional: true
  belongs_to :team, optional: true

  risk_color_enum :status, allow_nil: true
  enum :assignment_status, { assigned: 1, orphaned: 0 }

  after_commit :update_consecutive_green_status

  def tariki?(status_on_memory = nil, reference_time: Time.current,
              required_green_visits: AppConfigParam.tariki_required_green_visits,
              time_window: AppConfigParam.tariki_time_window)
    tariki_state(
      status_on_memory || status,
      reference_time:,
      required_green_visits:,
      time_window:
    )[:tariki_status]
  end

  def consecutive_green_status_calculation(reference_time: Time.current,
                                           required_green_visits: AppConfigParam.tariki_required_green_visits,
                                           time_window: AppConfigParam.tariki_time_window)
    tariki_state(
      status,
      reference_time:,
      required_green_visits:,
      time_window:
    )[:consecutive_green_status]
  end

  def current_tariki_state(required_green_visits: AppConfigParam.tariki_required_green_visits,
                           time_window: AppConfigParam.tariki_time_window)
    latest_visit = visits.reorder(visited_at: :desc, created_at: :desc).first
    return { tariki_status: false, consecutive_green_status: 0 } unless latest_visit

    tariki_state(
      latest_visit.status,
      reference_time: latest_visit.visited_at,
      required_green_visits:,
      time_window:
    )
  end

  private

  def tariki_state(status, reference_time:, required_green_visits:, time_window:)
    return { tariki_status: false, consecutive_green_status: 0 } unless status == Constants::RiskColor::GREEN

    reference_time = tariki_reference_time(reference_time)
    statuses = tariki_statuses_in_window(required_green_visits, reference_time, time_window)
    statuses.shift
    statuses.unshift(status)
    consecutive_green_status = statuses.take_while { |entry| entry == Constants::RiskColor::GREEN }.count

    {
      tariki_status: consecutive_green_status >= required_green_visits,
      consecutive_green_status:
    }
  end

  def tariki_reference_time(reference_time)
    return Time.current if reference_time.blank?
    return reference_time.end_of_day if reference_time.is_a?(Date) && !reference_time.is_a?(Time)

    parsed_time = if reference_time.respond_to?(:in_time_zone)
                    reference_time.in_time_zone
                  else
                    Time.zone.parse(reference_time.to_s)
                  end
    parsed_time || Time.current
  end

  def tariki_statuses_in_window(limit, reference_time, time_window)
    window_start = reference_time - time_window
    ranked_visits =
      visits.where(visited_at: window_start..reference_time)
            .select(
              <<~SQL.squish
                visits.status,
                visits.visited_at,
                visits.created_at,
                ROW_NUMBER() OVER (
                  PARTITION BY DATE(visits.visited_at)
                  ORDER BY visits.visited_at DESC, visits.created_at DESC
                ) AS daily_rank
              SQL
            )

    Visit.unscoped
         .from("(#{ranked_visits.to_sql}) daily_visits")
         .where('daily_rank = 1')
         .order(Arel.sql('daily_visits.visited_at DESC, daily_visits.created_at DESC'))
         .limit(limit)
         .pluck(Arel.sql('daily_visits.status'))
  end

  def update_consecutive_green_status
    update_column( # rubocop:disable Rails/SkipsModelValidations
      :consecutive_green_status,
      current_tariki_state[:consecutive_green_status]
    )
  end
end
