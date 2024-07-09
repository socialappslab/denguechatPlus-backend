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
#
# Indexes
#
#  index_user_profiles_on_city_id          (city_id)
#  index_user_profiles_on_neighborhood_id  (neighborhood_id)
#  index_user_profiles_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class UserProfile < ApplicationRecord
  has_one :user_profiles_role, dependent: :destroy
  has_one :role, through: :user_profiles_role
  has_one :user_account, dependent: :destroy, autosave: true
  has_one :city
  has_one :neighborhood

  delegate :confirmed_at, :phone, to: :user_account, allow_nil: true
  delegate :name, to: :role, prefix: true, allow_nil: true
end
