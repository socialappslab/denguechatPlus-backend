# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id              :bigint           not null, primary key
#  email           :string
#  first_name      :string
#  gender          :integer
#  language        :string
#  last_name       :string
#  points          :integer
#  timezone        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  city_id         :bigint
#  neighborhood_id :bigint
#  organization_id :bigint
#  team_id         :bigint
#
# Indexes
#
#  index_user_profiles_on_city_id          (city_id)
#  index_user_profiles_on_neighborhood_id  (neighborhood_id)
#  index_user_profiles_on_organization_id  (organization_id)
#  index_user_profiles_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (team_id => teams.id)
#
class UserProfile < ApplicationRecord
  has_one :user_account, autosave: true
  belongs_to :city
  belongs_to :neighborhood
  belongs_to :organization
  belongs_to :team, foreign_key: 'team_id', optional: true
  has_many :user_profile_house_blocks
  has_many :house_blocks, through: :user_profile_house_blocks


  delegate :confirmed_at, :phone, :username, :status, to: :user_account, allow_nil: true
  delegate :name, to: :role, prefix: true, allow_nil: true
  delegate :name, to: :team, prefix: true, allow_nil: true
  delegate :name, to: :organization, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :neighborhood, prefix: true, allow_nil: true
  delegate :roles, to: :user_account, allow_nil: true
end
