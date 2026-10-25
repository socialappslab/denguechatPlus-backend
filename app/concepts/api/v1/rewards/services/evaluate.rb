# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Services
        # Grants every usable reward level whose threshold the brigadista has reached.
        # Earned rewards are never revoked, so running it again is always safe.
        class Evaluate
          def self.call(...)
            new(...).call
          end

          def initialize(user_account:, trigger_visit: nil, seen: false)
            @user_account = user_account
            @trigger_visit = trigger_visit
            @seen = seen
          end

          def call
            return [] unless user_account

            values = Api::V1::Rewards::Queries::MetricValues.call(user_account)
            now = Time.current
            rows = reachable_levels(values).map do |level|
              {
                earner_type: 'UserAccount',
                earner_id: user_account.id,
                reward_level_id: level.id,
                trigger_visit_id: trigger_visit&.id,
                earned_at: now,
                count_at_earn: values[level.reward_type.metric],
                seen_at: seen ? now : nil
              }
            end
            return [] if rows.empty?

            # rubocop:disable Rails/SkipsModelValidations -- the unique index skips rewards already earned, even under races
            UserReward.insert_all(rows, unique_by: :index_user_rewards_on_earner_and_level, returning: %i[id])
                      .rows.flatten
            # rubocop:enable Rails/SkipsModelValidations
          end

          # Never lets a reward problem fail the visit or inspection request that triggered it.
          def self.safe_call(**)
            call(**)
          rescue StandardError => error
            Rails.logger.error("Rewards evaluation failed: #{error.message}")
            Sentry.capture_exception(error)
            []
          end

          private

          attr_reader :user_account, :trigger_visit, :seen

          def reachable_levels(values)
            RewardLevel.usable
                       .joins(:reward_type).merge(RewardType.usable)
                       .includes(:reward_type)
                       .select { |level| level.threshold <= values.fetch(level.reward_type.metric, 0) }
          end
        end
      end
    end
  end
end
