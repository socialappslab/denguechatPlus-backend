# frozen_string_literal: true


module Api
  module V1
    module Reports
      module Queries
        class HouseStatusWeb
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                                     :red_quantity, :site_variation_percentage, :visit_variation_percentage)


          def initialize(filter, current_user)
            @model = HouseStatus
            filter ||= {}
            @current_user = current_user
            @wedge_id =filter[:wedge_id]
            @team_id = filter[:team_id]
            @neighborhood_id =filter[:neighborhood_id]
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            fetch_data
          end

          private

          attr_reader :team_id, :wedge_id, :neighborhood_id

          def fetch_data
            current_week_query = <<-SQL.squish
    SELECT
      DISTINCT COUNT(house_statuses.house_id) AS house_quantity,
      COUNT(CASE WHEN (COALESCE(infected_containers, 0) = 0) AND (COALESCE(potential_containers, 0) = 0) THEN 1 END) AS green_quantity_current,
      SUM(CASE WHEN potential_containers > 0 AND (infected_containers = 0 OR infected_containers IS NULL) THEN 1 ELSE 0 END) AS orange_quantity,
      SUM(CASE WHEN infected_containers > 0 THEN 1 ELSE 0 END) AS red_quantity,
      (SELECT COUNT(*) 
       FROM visits 
       LEFT JOIN houses ON visits.house_id = houses.id 
       WHERE visits.team_id = ? 
         AND (houses.neighborhood_id = ? OR ? IS NULL) 
         AND (houses.wedge_id = ? OR ? IS NULL)
         AND visits.visited_at >= date_trunc('week', CURRENT_DATE)) AS visit_quantity_current,
      (SELECT COUNT(*) 
       FROM visits 
       LEFT JOIN houses ON visits.house_id = houses.id 
       WHERE visits.team_id = ?) AS visit_quantity_total,
      (SELECT COUNT(CASE WHEN (infected_containers = 0 OR infected_containers IS NULL) AND (potential_containers = 0 OR potential_containers IS NULL) THEN 1 END)
       FROM house_statuses 
       WHERE house_statuses.team_id = ? 
         AND house_statuses.date >= date_trunc('week', CURRENT_DATE)) AS green_quantity_cw
    FROM
      house_statuses
    WHERE
      house_statuses.team_id = ? 
      AND (house_statuses.neighborhood_id = ? OR ? IS NULL) 
      AND (house_statuses.wedge_id IN (?) OR ? IS NULL)
      AND house_statuses.date >= date_trunc('week', CURRENT_DATE)
SQL

            previous_week_query = <<-SQL.squish
    SELECT
      DISTINCT COUNT(house_statuses.house_id) AS house_quantity_previous,
      COUNT(CASE WHEN (COALESCE(infected_containers, 0) = 0) AND (COALESCE(potential_containers, 0) = 0) THEN 1 END) AS green_quantity_previous,
      (SELECT COUNT(*) 
       FROM visits 
       LEFT JOIN houses ON visits.house_id = houses.id 
       WHERE visits.team_id = ? 
         AND (houses.neighborhood_id = ? OR ? IS NULL) 
         AND (houses.wedge_id = ? OR ? IS NULL)
         AND visits.visited_at >= date_trunc('week', CURRENT_DATE) - INTERVAL '7 days' 
         AND visits.visited_at < date_trunc('week', CURRENT_DATE)) AS visit_quantity_previous
    FROM
      house_statuses
    WHERE
      house_statuses.team_id = ? 
      AND house_statuses.date >= date_trunc('week', CURRENT_DATE) - INTERVAL '7 days' 
      AND house_statuses.date < date_trunc('week', CURRENT_DATE)
      AND (house_statuses.neighborhood_id = ? OR ? IS NULL) 
      AND (house_statuses.wedge_id = ? OR ? IS NULL)
SQL


            cw = ActiveRecord::Base.connection.execute(
              ActiveRecord::Base.send(:sanitize_sql_array, [
                current_week_query,
                @team_id,
                @neighborhood_id,
                @neighborhood_id,
                @wedge_id,
                @wedge_id,
                @team_id,
                @team_id,
                @team_id,
                @neighborhood_id,
                @neighborhood_id,
                @wedge_id,
                @wedge_id
              ])
            ).to_a&.first

            pw = ActiveRecord::Base.connection.execute(
              ActiveRecord::Base.send(:sanitize_sql_array, [
                previous_week_query,
                @team_id,
                @neighborhood_id,
                @neighborhood_id,
                @wedge_id,
                @wedge_id,
                @team_id,
                @neighborhood_id,
                @neighborhood_id,
                @wedge_id,
                @wedge_id
              ])
            ).to_a&.first
            #:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
            #                                      :red_quantity, :site_variation_percentage, :visit_variation_percentage

            visit_variation_percentage = pw['visit_quantity_previous'].to_i.zero? ? nil : ((cw['visit_quantity_current'] - pw['visit_quantity_previous']) * 100.0 / pw['visit_quantity_previous']).round(0)

            site_variation_percentage = if pw['green_quantity_previous'].nil? || (pw['green_quantity_previous']).zero?
                                          cw['green_quantity_cw'].to_i.positive? ? 100 : 0
                                        else
                                          ((cw['green_quantity_cw'] - pw['green_quantity_previous']) * 100 / pw['green_quantity_previous']).round(0)
                                        end

            StatusResults.new(
              cw['house_quantity'] || nil,
              cw['visit_quantity_total'] || nil,
              cw['green_quantity_current'] || nil,
              cw['orange_quantity'] || nil,
              cw['red_quantity'] || nil,
              site_variation_percentage,
              visit_variation_percentage
            )
          end

        end
      end
    end
  end
end
