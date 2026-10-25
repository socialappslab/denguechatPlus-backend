# frozen_string_literal: true

# == Schema Information
#
# Table name: reward_types
#
#  id           :bigint           not null, primary key
#  active       :boolean          default(TRUE), not null
#  code         :string           not null
#  discarded_at :datetime
#  metric       :string           not null
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  position     :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_reward_types_on_code          (code) UNIQUE
#  index_reward_types_on_discarded_at  (discarded_at)
#
class RewardType < ApplicationRecord
  include Discard::Model

  METRICS = %w[worked_houses positive_containers].freeze

  has_many :reward_levels, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :metric, inclusion: { in: METRICS }

  scope :usable, -> { kept.where(active: true).order(:position, :id) }

  def localized_name(language)
    public_send("name_#{language}").presence || name_es
  end
end
