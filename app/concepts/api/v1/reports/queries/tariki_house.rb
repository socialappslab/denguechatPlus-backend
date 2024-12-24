# frozen_string_literal: true


module Api
  module V1
    module Reports
      module Queries
        class TarikiHouse
          include Api::V1::Lib::Queries::QueryHelper

          ReportResult = Struct.new(:total_houses_qty, :tariki_houses_qty)


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

            result = ActiveRecord::Base.connection.execute(query)

            ReportResult.new(
              House.where(neighborhood_id: sector_id).count,
              result.first&.[]('tariki_count')
            )
          end

        end
      end
    end
  end
end
