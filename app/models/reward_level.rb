# frozen_string_literal: true

# == Schema Information
#
# Table name: reward_levels
#
#  id               :bigint           not null, primary key
#  active           :boolean          default(TRUE), not null
#  code             :string           not null
#  color_background :string
#  color_primary    :string
#  color_secondary  :string
#  description_en   :string
#  description_es   :string
#  description_pt   :string
#  discarded_at     :datetime
#  name_en          :string
#  name_es          :string
#  name_pt          :string
#  position         :integer          default(0), not null
#  ring_gradient    :string
#  threshold        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  reward_type_id   :bigint           not null
#
# Indexes
#
#  index_reward_levels_on_discarded_at                  (discarded_at)
#  index_reward_levels_on_reward_type_id                (reward_type_id)
#  index_reward_levels_on_reward_type_id_and_code       (reward_type_id,code) UNIQUE
#  index_reward_levels_on_reward_type_id_and_threshold  (reward_type_id,threshold)
#
# Foreign Keys
#
#  fk_rails_...  (reward_type_id => reward_types.id)
#
class RewardLevel < ApplicationRecord
  include Discard::Model

  belongs_to :reward_type
  has_many :user_rewards, dependent: :destroy
  has_one_attached :image
  has_one_attached :locked_image

  validates :code, presence: true, uniqueness: { scope: :reward_type_id }
  validates :threshold, numericality: { only_integer: true, greater_than: 0 }

  scope :usable, -> { kept.where(active: true).order(:position, :threshold, :id) }

  def localized_name(language)
    public_send("name_#{language}").presence || name_es
  end

  def localized_description(language)
    public_send("description_#{language}").presence || description_es
  end
end
