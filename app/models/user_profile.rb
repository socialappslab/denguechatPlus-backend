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
class UserProfile < ApplicationRecord
  has_one :user_account, autosave: true
  belongs_to :city
  belongs_to :neighborhood
  belongs_to :organization
  belongs_to :team, optional: true
  has_many :user_profile_house_blocks
  has_many :house_blocks, through: :user_profile_house_blocks
  belongs_to :avatar, optional: true
  belongs_to :equipped_reward_level, class_name: 'RewardLevel', optional: true

  before_validation :assign_default_avatar, on: :create

  # Run after the avatar catalog has been seeded. The predicate also preserves concurrent selections.
  def self.backfill_default_avatar!
    default_avatar = Avatar.catalog.find_by!(base_code: Avatar::DEFAULT_BASE_CODE)
    where(avatar_id: nil).update_all(avatar_id: default_avatar.id)
  end

  delegate :confirmed_at, :phone, :username, :status, to: :user_account, allow_nil: true
  delegate :name, to: :role, prefix: true, allow_nil: true
  delegate :name, to: :team, prefix: true, allow_nil: true
  delegate :name, to: :organization, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :neighborhood, prefix: true, allow_nil: true
  delegate :roles, to: :user_account, allow_nil: true

  def full_name
    "#{first_name} #{last_name}"
  end

  # The skin the avatar wears: the one the brigadista picked, otherwise the highest skin earned.
  def worn_skin_id
    return equipped_reward_level_id if skin_manually_chosen
    return unless avatar && user_account

    user_account.user_rewards
                .joins(:reward_level)
                .where(reward_level_id: Avatar.kept.where(base_code: avatar.base_code).select(:reward_level_id))
                .order('reward_levels.threshold DESC')
                .pick(:reward_level_id)
  end

  def avatar_url
    image = avatar&.variant_for(worn_skin_id)&.image
    return unless image&.attached?

    Rails.application.routes.url_helpers.url_for(image)
  end

  private

  def assign_default_avatar
    # Profiles can be seeded before the avatar catalog; the post-seed backfill covers those.
    self.avatar ||= Avatar.catalog.find_by(base_code: Avatar::DEFAULT_BASE_CODE) if avatar_id.nil?
  end
end
