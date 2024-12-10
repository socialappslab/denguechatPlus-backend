# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatusMobile
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
            calculate_counters
          end

          private

          def calculate_counters
            base_filter = {}

            if @filter[:team_id]
              base_filter[:team_id] = @filter[:team_id]
            end

            if @filter[:wedge_id]
              base_filter[:wedge_id] = @filter[:wedge_id]
            end

            if @filter[:sector_id]
              base_filter[:neighborhood_id] = @filter[:sector_id]
            end

            if @filter[:neighborhood_id]
              base_filter[:neighborhood_id] = @filter[:neighborhood_id]
            end

            start_date = Date.today.beginning_of_week.to_date
            end_date = Date.today.end_of_week.to_date
            previous_start_date = 1.week.ago.beginning_of_week.to_date
            previous_end_date = 1.week.ago.end_of_week.to_date

            current_data = Visit
                             .joins(:house)
                             .select(
                               "COUNT(DISTINCT CASE WHEN visits.visited_at BETWEEN '#{start_date}' AND '#{end_date}' THEN houses.id END) AS sites_this_week",
                               "COUNT(DISTINCT houses.id) AS current_sites_count_total",
                               "COUNT(CASE WHEN visits.visited_at BETWEEN '#{start_date}' AND '#{end_date}' THEN visits.id END) AS visits_this_week",
                               "COUNT(visits.id) AS visits_total",
                               "COUNT(DISTINCT houses.id) AS houses_total"
                             )
                             .where(houses: base_filter)
                             .take



            previous_data = Visit
                              .joins(:house)
                              .select(
                                "COUNT(DISTINCT CASE WHEN visits.visited_at BETWEEN '#{previous_start_date}' AND '#{previous_end_date}' THEN houses.id END) AS sites_previous_week",
                                "COUNT(CASE WHEN visits.visited_at BETWEEN '#{previous_start_date}' AND '#{previous_end_date}' THEN visits.id END) AS visits_previous_week",
                                )
                              .where(houses: base_filter)
                              .take


            house_current_status = HouseStatus
                                     .joins(:house)
                                     .select("houses.status, COUNT(distinct houses.id) AS house_count")
                                     .where(houses: base_filter)
                                     .group("houses.status")


            status_counts = house_current_status.each_with_object({}) do |status, counts|
              counts[status.status] = status.house_count.to_i
            end

            green_quantity = status_counts["0"] || 0
            yellow_quantity = status_counts["1"] || 0
            red_quantity = status_counts["2"] || 0



            current_visits = current_data&.visits_this_week.to_i
            previous_visits = previous_data&.visits_previous_week.to_i
            visit_variation_percentage = calculate_percentage_variation(current_visits, previous_visits)
            site_variation_percentage = calculate_percentage_variation(current_data.current_sites_count_total, previous_data.sites_previous_week)


            StatusResults.new(
              current_data.current_sites_count_total,
              current_data.visits_total,
              green_quantity,
              yellow_quantity,
              red_quantity,
              site_variation_percentage,
              visit_variation_percentage
            )

          end

          def calculate_percentage_variation(current, previous)
            return 0 if previous.zero?
            ((current - previous) / previous.to_f * 100).round(2)
          end

          def get_team_id
            @filter[:team_id] || @current_user&.teams&.first&.id
          end
        end
      end
    end
  end
end
