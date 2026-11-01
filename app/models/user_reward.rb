# frozen_string_literal: true

# == Schema Information
#
# Table name: user_rewards
#
#  id               :bigint           not null, primary key
#  count_at_earn    :integer          not null
#  earned_at        :datetime         not null
#  earner_type      :string           not null
#  seen_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  earner_id        :bigint           not null
#  reward_level_id  :bigint           not null
#  trigger_visit_id :bigint
#
# Indexes
#
#  index_user_rewards_on_earner_and_level  (earner_type,earner_id,reward_level_id) UNIQUE
#  index_user_rewards_on_reward_level_id   (reward_level_id)
#  index_user_rewards_on_trigger_visit_id  (trigger_visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (reward_level_id => reward_levels.id)
#  fk_rails_...  (trigger_visit_id => visits.id)
#
class UserReward < ApplicationRecord
  belongs_to :earner, polymorphic: true
  belongs_to :reward_level
  belongs_to :trigger_visit, class_name: 'Visit', optional: true
end
