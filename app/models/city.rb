# == Schema Information
#
# Table name: cities
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :bigint           not null
#  state_id     :bigint           not null
#
# Indexes
#
#  index_cities_on_country_id                                (country_id)
#  index_cities_on_name_and_discarded_at                     (name,discarded_at) UNIQUE
#  index_cities_on_state_id                                  (state_id)
#  index_cities_on_state_id_and_country_id_and_discarded_at  (state_id,country_id,discarded_at) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (state_id => states.id)
#
class City < ApplicationRecord
  include Discard::Model

  belongs_to :state
  belongs_to :country

  has_many :neighborhoods, dependent: :destroy
  has_many :user_profiles
  accepts_nested_attributes_for :neighborhoods, allow_destroy: true

end
