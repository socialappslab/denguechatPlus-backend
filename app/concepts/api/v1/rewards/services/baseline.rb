# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Services
        class Baseline
          def self.call(user_account)
            return unless user_account

            values = Api::V1::Rewards::Queries::MetricValues.call(user_account)
            RewardLevel.usable.joins(:reward_type).merge(RewardType.usable).includes(:reward_type).to_h do |level|
              [level.id, { threshold: level.threshold, metric: level.reward_type.metric,
                           value: values.fetch(level.reward_type.metric, 0) }]
            end
          rescue StandardError => error
            Rails.logger.error("Reward baseline failed: #{error.message}")
            nil
          end
        end
      end
    end
  end
end
