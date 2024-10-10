# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatus
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                                     :red_quantity, :site_variation_percentage, :visit_variation_percentage)

          def initialize(filter, current_user)
            @model = ::HouseStatus
            @filter = filter || {}
            @current_user = current_user
          end

          def self.call(...)
            new(...).call
          end

          def call
            result = house_statuses_with_aggregates&.first

            house_quantity = result['house_quantity'] || 0
            visit_quantity = result['visit_quantity'] || 0
            green_quantity = result['green_quantity'] || 0
            orange_quantity = result['orange_quantity'] || 0
            red_quantity = result['red_quantity'] || 0
            site_variation_percentage = result['green_quantity_change_percentage'] || 0
            visit_variation_percentage = result['visit_quantity_change_percentage'] || 0

            StatusResults.new(
              house_quantity,
              visit_quantity,
              green_quantity,
              orange_quantity,
              red_quantity,
              site_variation_percentage,
              visit_variation_percentage
            )
          end

          private

          def house_statuses_with_aggregates
            sql = <<-SQL
              WITH current_week AS (
                SELECT 
                    COUNT(*) AS house_quantity,
                    COUNT(
                        CASE 
                            WHEN (infected_containers = 0 OR infected_containers IS NULL) 
                                 AND (potential_containers = 0 OR potential_containers IS NULL) 
                            THEN 1 
                        END
                    ) AS green_quantity_current,
                    SUM(
                        CASE 
                            WHEN potential_containers > 0 
                                 AND (infected_containers = 0 OR infected_containers IS NULL) 
                            THEN 1 
                            ELSE 0 
                        END
                    ) AS orange_quantity,
                    SUM(
                        CASE 
                            WHEN infected_containers > 0 
                            THEN 1 
                            ELSE 0 
                        END
                    ) AS red_quantity,
                    (SELECT COUNT(*) 
                     FROM "visits" 
                     WHERE "visits"."team_id" = ?) AS visit_quantity_total,
                    (SELECT COUNT(*) 
                     FROM "visits" 
                     WHERE "visits"."team_id" = ?
                       AND "visits"."visited_at" >= CURRENT_DATE - INTERVAL '7 days') AS visit_quantity_current
                FROM 
                    "house_statuses"
                WHERE 
                    "house_statuses"."team_id" = ?
                AND "house_statuses"."created_at" >= CURRENT_DATE - INTERVAL '7 days'
            ),
            previous_week AS (
                SELECT 
                    COUNT(*) AS house_quantity_previous,
                    COUNT(
                        CASE 
                            WHEN (infected_containers = 0 OR infected_containers IS NULL) 
                                 AND (potential_containers = 0 OR potential_containers IS NULL) 
                            THEN 1 
                        END
                    ) AS green_quantity_previous,
                    (SELECT COUNT(*) 
                     FROM "visits" 
                     WHERE "visits"."team_id" = ?
                       AND "visits"."visited_at" >= CURRENT_DATE - INTERVAL '14 days'
                       AND "visits"."visited_at" < CURRENT_DATE - INTERVAL '7 days') AS visit_quantity_previous
                FROM 
                    "house_statuses"
                WHERE 
                    "house_statuses"."team_id" = ?
               AND "house_statuses"."created_at" >= CURRENT_DATE - INTERVAL '14 days'
               AND "house_statuses"."created_at" < CURRENT_DATE - INTERVAL '7 days'
            )
            SELECT 
                cw.house_quantity AS house_quantity,
                cw.green_quantity_current AS green_quantity,
                cw.orange_quantity AS orange_quantity,
                cw.red_quantity AS red_quantity,
                cw.visit_quantity_total AS visit_quantity,
                CASE 
                    WHEN pw.green_quantity_previous IS NULL OR pw.green_quantity_previous = 0
                    AND (cw.green_quantity_current IS NOT NULL AND cw.green_quantity_current > 0)
                    THEN 
                        100.00
                    ELSE ROUND(
                        (cw.green_quantity_current - pw.green_quantity_previous) 
                        * 100.0 / pw.green_quantity_previous, 2
                    ) 
                END AS green_quantity_change_percentage,
                CASE 
                    WHEN pw.visit_quantity_previous = 0 THEN NULL 
                    ELSE ROUND(
                        (cw.visit_quantity_current - pw.visit_quantity_previous) 
                        * 100.0 / pw.visit_quantity_previous, 2
                    )
                END AS visit_quantity_change_percentage
            FROM 
                current_week cw, 
                previous_week pw;
            SQL
            team_id = get_team_id
            res = @model.connection.select_all(
              @model.sanitize_sql_array([sql, team_id, team_id, team_id, team_id, team_id])
            )
            res
          end

          def get_team_id
            @filter[:team_id] || @current_user&.teams&.first&.id
          end
        end
      end
    end
  end
end
