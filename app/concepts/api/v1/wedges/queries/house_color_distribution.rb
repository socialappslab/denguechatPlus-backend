# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Queries
        class HouseColorDistribution
          COLORS = %w[green yellow red].freeze

          def initialize(wedge_id, from:, to:)
            @wedge_id = wedge_id
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
                green: count_houses_by_status('green', period[:end_date]),
                yellow: count_houses_by_status('yellow', period[:end_date]),
                red: count_houses_by_status('red', period[:end_date])
              }
            end
          end

          private

          def periods
            @periods ||= generate_periods
          end

          def generate_periods
            result = []
            current_start = @from.beginning_of_month

            while current_start <= @to
              current_end = [current_start.end_of_month, @to].min
              result << {
                label: current_start.strftime('%b'),
                start_date: current_start,
                end_date: current_end
              }
              current_start += 1.month
            end

            result
          end

          def count_houses_by_status(status, as_of_date)
            latest_statuses_sql = HouseStatus
                                  .where(wedge_id: @wedge_id)
                                  .where(date: ..as_of_date)
                                  .select('DISTINCT ON (house_id) house_id, status')
                                  .order(:house_id, date: :desc)
                                  .to_sql

            sql = <<~SQL.squish
              SELECT COUNT(*) FROM (#{latest_statuses_sql}) AS latest_statuses
              WHERE latest_statuses.status = '#{status}'
            SQL
            ActiveRecord::Base.connection.execute(sql).first['count'].to_i
          end
        end
      end
    end
  end
end
