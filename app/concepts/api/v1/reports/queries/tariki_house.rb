# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class TarikiHouse
          include Api::V1::Lib::Queries::QueryHelper

          ReportResult = Struct.new(:total_houses_qty, :tariki_houses_qty, :total_container_qty, :green_container_qty)

          def initialize(filter, current_user)
            @model = HouseStatus
            filter ||= {}
            @filter = filter
            @current_user = current_user
          end

          def self.call(...)
            new(...).call
          end

          def call
            fetch_data
          end

          private

          attr_reader :neighborhood_id

          def fetch_data
            sector_id = @current_user.teams&.first&.neighborhood_id || 0
            month_range = Time.current.beginning_of_month...Time.current.next_month.beginning_of_month
            tariki_reference_time = Time.current
            tariki_window_start = ActiveRecord::Base.connection.quote(tariki_reference_time - House::TARIKI_TIME_WINDOW)
            tariki_window_end = ActiveRecord::Base.connection.quote(tariki_reference_time)
            monthly_inspections = Inspection.joins(visit: :house)
                                            .merge(Visit.kept)
                                            .where(houses: { neighborhood_id: sector_id })
                                            .where(inspections: { created_at: month_range })

            query = <<~SQL.squish
              WITH daily_visits AS (
                SELECT visits.house_id, visits.status, visits.visited_at, visits.created_at,
                       houses.neighborhood_id,
                       ROW_NUMBER() OVER (
                         PARTITION BY visits.house_id, DATE(visits.visited_at)
                         ORDER BY visits.visited_at DESC, visits.created_at DESC
                       ) AS daily_rn
                FROM visits
                INNER JOIN houses ON houses.id = visits.house_id
                WHERE visits.visited_at BETWEEN #{tariki_window_start} AND #{tariki_window_end}
                  AND visits.discarded_at IS NULL
              )
              , last_4_statuses AS (
                SELECT house_id, status, neighborhood_id,
                       ROW_NUMBER() OVER (
                         PARTITION BY house_id
                         ORDER BY visited_at DESC, created_at DESC
                       ) AS rn
                FROM daily_visits
                WHERE daily_rn = 1
              )
              , filtered_statuses AS (
                SELECT house_id, status, neighborhood_id
                FROM last_4_statuses
                WHERE rn <= 4
              )
              , house_status_counts AS (
                SELECT house_id, neighborhood_id,
                       COUNT(CASE WHEN status = 'green' THEN 1 END) AS green_status_count
                FROM filtered_statuses
                GROUP BY house_id, neighborhood_id
              )
              SELECT COUNT(*) AS tariki_count
              FROM house_status_counts
              WHERE green_status_count = 4
                AND neighborhood_id = #{sector_id};
            SQL

            tariki_houses_qty = ActiveRecord::Base.connection.execute(query)

            ReportResult.new(
              House.where(neighborhood_id: sector_id).count,
              tariki_houses_qty.first&.[]('tariki_count'),
              monthly_inspections.count,
              monthly_inspections.where(color: 'green').count
            )
          end
        end
      end
    end
  end
end
