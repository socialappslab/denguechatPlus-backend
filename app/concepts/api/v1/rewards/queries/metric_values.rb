# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Queries
        # Current value of every reward metric for one brigadista, keyed by RewardType::METRICS.
        class MetricValues
          def self.call(...)
            new(...).call
          end

          def initialize(user_account)
            @user_account = user_account
          end

          def call
            {
              'worked_houses' => worked_houses,
              'positive_containers' => positive_containers
            }
          end

          private

          attr_reader :user_account

          # A worked house is a visit with permission granted, counted once per house per local day.
          def worked_houses
            local_day = "(visits.visited_at AT TIME ZONE 'UTC' AT TIME ZONE '#{Time.zone.tzinfo.name}')::date"

            Visit.joins(:visit_permission_option)
                 .where(user_account_id: user_account.id, options: { value: '1' })
                 .where.not(visited_at: nil)
                 .distinct
                 .count(Arel.sql("(visits.house_id, #{local_day})"))
          end

          def positive_containers
            Inspection.joins(:visit)
                      .where(visits: { user_account_id: user_account.id }, color: Constants::RiskColor::RED)
                      .count
          end
        end
      end
    end
  end
end
