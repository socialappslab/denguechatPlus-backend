# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class RiskChange
          COLORS = %w[green yellow red].freeze

          def initialize(team_id, from:, to:)
            @team_id = team_id
            @from = from || 6.months.ago.to_date
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            periods.map do |period|
              {
                period: period[:label],
                start_date: period[:start_date],
                end_date: period[:end_date],
                green: count_houses_by_status('green', period[:start_date], period[:end_date]),
                yellow: count_houses_by_status('yellow', period[:start_date], period[:end_date]),
                red: count_houses_by_status('red', period[:start_date], period[:end_date])
              }
            end
          end

          private

          def periods
            @periods ||= generate_periods
          end

          def generate_periods
            result = []
            current_start = @from.beginning_of_week
            period_index = 1

            while current_start <= @to
              current_end = [current_start.end_of_week, @to].min
              result << {
                label: "W#{period_index}",
                start_date: current_start,
                end_date: current_end
              }
              current_start += 1.week
              period_index += 1
            end

            result
          end

          def count_houses_by_status(status, start_date, end_date)
            HouseStatus
              .where(team_id: @team_id)
              .where(date: start_date..end_date)
              .where(status: status)
              .distinct
              .count(:house_id)
          end
        end
      end
    end
  end
end
