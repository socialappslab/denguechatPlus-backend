# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Serializers
        # Every usable reward track with the brigadista's progress, as embedded in users/me.
        # A level counts as earned once a reward row exists or the metric already reached its threshold,
        # so new or lowered thresholds show up before the next evaluation writes the row.
        class Summary
          def self.call(...)
            new(...).call
          end

          def initialize(user_account, language: 'es')
            @user_account = user_account
            @language = language
          end

          def call
            values = Api::V1::Rewards::Queries::MetricValues.call(user_account)
            user_rewards = user_account.user_rewards.index_by(&:reward_level_id)
            levels_by_type = RewardLevel.usable.with_attached_image.with_attached_locked_image
                                        .group_by(&:reward_type_id)

            RewardType.usable.map do |reward_type|
              current_value = values.fetch(reward_type.metric, 0)
              levels = levels_by_type.fetch(reward_type.id, []).map do |level|
                level_hash(level, current_value, user_rewards[level.id])
              end

              {
                code: reward_type.code,
                name: reward_type.localized_name(language),
                metric: reward_type.metric,
                currentValue: current_value,
                nextLevel: next_level(levels, current_value),
                levels:
              }
            end
          end

          private

          attr_reader :user_account, :language

          def level_hash(level, current_value, user_reward)
            {
              id: level.id,
              code: level.code,
              name: level.localized_name(language),
              description: level.localized_description(language),
              threshold: level.threshold,
              position: level.position,
              earned: user_reward.present? || current_value >= level.threshold,
              earnedAt: user_reward&.earned_at,
              new: user_reward.present? && user_reward.seen_at.nil?,
              imageUrl: url_for(level.image),
              lockedImageUrl: url_for(level.locked_image),
              colorPrimary: level.color_primary,
              colorSecondary: level.color_secondary,
              colorBackground: level.color_background,
              ringGradient: level.ring_gradient.to_s.split(',').map(&:strip)
            }
          end

          def next_level(levels, current_value)
            level = levels.reject { |item| item[:earned] }.min_by { |item| item[:threshold] }
            return unless level

            level.slice(:id, :code, :name, :threshold).merge(remaining: level[:threshold] - current_value)
          end

          def url_for(attachment)
            return unless attachment.attached?

            Rails.application.routes.url_helpers.url_for(attachment)
          end
        end
      end
    end
  end
end
