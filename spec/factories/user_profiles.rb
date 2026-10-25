# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id                       :bigint           not null, primary key
#  email                    :string
#  first_name               :string
#  gender                   :integer
#  language                 :string
#  last_name                :string
#  points                   :integer
#  skin_manually_chosen     :boolean          default(FALSE), not null
#  timezone                 :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  avatar_id                :bigint
#  city_id                  :bigint
#  equipped_reward_level_id :bigint
#  neighborhood_id          :bigint
#  organization_id          :bigint
#  team_id                  :bigint
#
# Indexes
#
#  index_user_profiles_on_avatar_id                 (avatar_id)
#  index_user_profiles_on_city_id                   (city_id)
#  index_user_profiles_on_equipped_reward_level_id  (equipped_reward_level_id)
#  index_user_profiles_on_neighborhood_id           (neighborhood_id)
#  index_user_profiles_on_organization_id           (organization_id)
#  index_user_profiles_on_team_id                   (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (equipped_reward_level_id => reward_levels.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :user_profile do
    transient do
      password { 'Password1' }
    end

    first_name { FFaker::Name.unique.first_name }
    last_name { FFaker::Name.unique.last_name }
    country { FFaker::Address.country }
    city { FFaker::Address.city }
    phone_number { "#{FFaker::PhoneNumber.area_code}#{FFaker::PhoneNumber.short_phone_number.delete('-')}" }
    points { 0 }
    timezone { 'utc-4' }
    language { 'es' }
    gender { 1 }

    trait :with_account do
      transient do
        password { 'Password1' }
        email { FFaker::Internet.email }
        locked { false }
        locked_at { nil }
        discarded_at { nil }
        confirmed_at { Time.current }
      end

      after(:create) do |user_profile, evaluator|
        create(
          :user_account,
          user_profile:,
          password: evaluator.password,
          email: evaluator.email || FFaker::Internet.unique.email,
          locked: evaluator.locked,
          locked_at: evaluator.locked_at,
          discarded_at: evaluator.discarded_at,
          confirmed_at: evaluator.confirmed_at
        )
      end
    end
  end
end
