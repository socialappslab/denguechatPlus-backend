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
            monthly_inspections = Inspection.joins(visit: :house)
                                            .merge(Visit.kept)
                                            .where(houses: { neighborhood_id: sector_id })
                                            .where(inspections: { created_at: month_range })
            houses = House.where(neighborhood_id: sector_id)

            ReportResult.new(
              houses.count,
              houses.where(tariki_status: true).count,
              monthly_inspections.count,
              monthly_inspections.where(color: 'green').count
            )
          end
        end
      end
    end
  end
end
