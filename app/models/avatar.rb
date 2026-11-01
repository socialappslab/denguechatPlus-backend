# frozen_string_literal: true

# == Schema Information
#
# Table name: avatars
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  base_code       :string           not null
#  discarded_at    :datetime
#  position        :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reward_level_id :bigint
#
# Indexes
#
#  index_avatars_on_base_code_and_reward_level_id  (base_code,reward_level_id) UNIQUE
#  index_avatars_on_base_code_without_skin         (base_code) UNIQUE WHERE (reward_level_id IS NULL)
#  index_avatars_on_reward_level_id                (reward_level_id)
#
# Foreign Keys
#
#  fk_rails_...  (reward_level_id => reward_levels.id)
#
# One avatar picture. Rows without a reward level are the catalog the brigadista picks from;
# rows with one are the same base avatar wearing that skin.
class Avatar < ApplicationRecord
  include Discard::Model

  belongs_to :reward_level, optional: true
  has_one_attached :image

  scope :catalog, -> { kept.where(active: true, reward_level_id: nil).order(:position, :id) }

  def variant_for(skin_id)
    return self unless skin_id

    Avatar.kept.find_by(base_code:, reward_level_id: skin_id) || self
  end
end
