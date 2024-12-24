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
            sector_id = @current_user.neighborhood_id
            query = <<~SQL.squish
              WITH last_4_statuses AS (
                SELECT house_id, status, updated_at, neighborhood_id,
                       ROW_NUMBER() OVER (PARTITION BY house_id ORDER BY updated_at DESC) AS rn
                FROM house_statuses
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

            query_green_containers = <<~SQL.squish
              SELECT
                  COUNT(*) FILTER (WHERE inspections.color = 'green') AS green_container_qty,
                  COUNT(*) AS total_container_qty
              FROM inspections
              LEFT JOIN visits ON inspections.visit_id = visits.id
              LEFT JOIN houses ON visits.house_id = houses.id
              WHERE houses.neighborhood_id = #{sector_id}
              AND inspections.created_at >= DATE_TRUNC('month', NOW())
              AND inspections.created_at < DATE_TRUNC('month', NOW()) + INTERVAL '1 month';
            SQL

            tariki_houses_qty = ActiveRecord::Base.connection.execute(query)
            green_containers = ActiveRecord::Base.connection.execute(query_green_containers)

            ReportResult.new(
              House.where(neighborhood_id: sector_id).count,
              tariki_houses_qty.first&.[]('tariki_count'),
              green_containers.first&.[]('total_container_qty'),
              green_containers.first&.[]('green_container_qty')
            )
          end

        end
      end
    end
  end
end
