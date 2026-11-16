# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Serializers
        class VisitAwards
          def self.call(visit)
            ids = Array(visit.earned_reward_ids)
            return [] if ids.empty?

            Summary.call(visit.user_account, language: visit.language)
                   .flat_map { |track| track[:levels].map { |level| level.merge(metric: track[:metric]) } }
                   .select { |level| ids.include?(level[:userRewardId]) }
          rescue StandardError => error
            Rails.logger.error("Visit reward serialization failed: #{error.message}")
            Sentry.capture_exception(error)
            []
          end
        end
      end
    end
  end
end
