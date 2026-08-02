# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatusWeb
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(
            :house_quantity, :visit_quantity, :site_variation_percentage, :visit_variation_percentage,
            :green_quantity, :orange_quantity, :red_quantity
          )

          def initialize(filter, current_user)
            @filter = filter || {}
            @current_user = current_user
          end

          def self.call(...)
            new(...).call
          end

          def call
            fetch_data
          end

          private

          def fetch_data
            status_counts = latest_active_visits
                            .where.not(status: nil)
                            .group('visits.status')
                            .count

            StatusResults.new(
              0,
              0,
              0,
              0,
              status_counts[Constants::RiskColor::GREEN] || 0,
              status_counts[Constants::RiskColor::YELLOW] || 0,
              status_counts[Constants::RiskColor::RED] || 0
            )
          end

          def latest_active_visits
            visits = Visit
                     .select('DISTINCT ON (visits.house_id) visits.id, visits.house_id, visits.status, visits.team_id')
                     .order(Arel.sql("visits.house_id, #{Visit.latest_first_order}"))

            latest_visits = Visit
                            .unscoped
                            .from("(#{visits.to_sql}) visits")
                            .joins('INNER JOIN houses ON houses.id = visits.house_id')
                            .where(houses: { city_id: @current_user.city_id, discarded_at: nil })
                            .yield_self(&method(:house_location_filters))
            return latest_visits if @filter[:team_id].blank?

            latest_visits.where(team_id: @filter[:team_id])
          end

          def house_location_filters(relation)
            relation = relation.where(houses: { wedge_id: @filter[:wedge_id] }) if @filter[:wedge_id].present?
            neighborhood_id = @filter[:neighborhood_id].presence || @filter[:sector_id].presence
            return relation if neighborhood_id.blank?

            relation.where(houses: { neighborhood_id: })
          end
        end
      end
    end
  end
end
