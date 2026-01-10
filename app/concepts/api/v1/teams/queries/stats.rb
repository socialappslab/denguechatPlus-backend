# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class Stats
          StatsResult = Struct.new(
            :id,
            :houses_visited,
            :positive_containers,
            :coverage_percentage,
            :houses_with_aedes_percentage,
            :house_access_status,
            :container_positives,
            :risk_change,
            :house_color_distribution,
            keyword_init: true
          )

          def initialize(team_id, from:, to:)
            @team_id = team_id
            @from = from
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            StatsResult.new(
              id: @team_id,
              houses_visited: houses_visited,
              positive_containers: positive_containers,
              coverage_percentage: coverage_percentage,
              houses_with_aedes_percentage: houses_with_aedes_percentage,
              house_access_status: house_access_status,
              container_positives: container_positives,
              risk_change: risk_change,
              house_color_distribution: house_color_distribution
            )
          end

          private

          def visit_scope
            scope = Visit.where(team_id: @team_id)
            scope = scope.where(visits: { visited_at: @from.beginning_of_day.. }) if @from
            scope.where(visits: { visited_at: ..@to.end_of_day })
          end

          def inspection_scope
            scope = Inspection.joins(:visit).where(visits: { team_id: @team_id })
            scope = scope.where(inspections: { created_at: @from.beginning_of_day.. }) if @from
            scope.where(inspections: { created_at: ..@to.end_of_day })
          end

          def house_status_scope
            scope = HouseStatus.where(team_id: @team_id)
            scope = scope.where(house_statuses: { date: @from.. }) if @from
            scope.where(house_statuses: { date: ..@to })
          end

          def houses_visited
            visit_scope.distinct.count(:house_id)
          end

          def positive_containers
            inspection_scope.where(color: %w[yellow red]).count
          end

          def coverage_percentage
            total_houses = houses_visited
            return 0 if total_houses.zero?

            accessible_houses = visit_scope.joins(:visit_permission_option)
                                           .where(options: { value: '1' })
                                           .distinct
                                           .count(:house_id)

            ((accessible_houses.to_f / total_houses) * 100).round(2)
          end

          def houses_with_aedes_percentage
            total_houses = house_status_scope.distinct.count(:house_id)
            return 0 if total_houses.zero?

            red_houses = house_status_scope.where(status: 'red').distinct.count(:house_id)

            ((red_houses.to_f / total_houses) * 100).round(2)
          end

          def house_access_status
            HouseAccessStatus.call(@team_id, from: @from, to: @to)
          end

          def container_positives
            ContainerPositives.call(@team_id, from: @from, to: @to)
          end

          def risk_change
            RiskChange.call(@team_id, from: @from, to: @to)
          end

          def house_color_distribution
            HouseColorDistribution.call(@team_id, from: @from, to: @to)
          end
        end
      end
    end
  end
end
