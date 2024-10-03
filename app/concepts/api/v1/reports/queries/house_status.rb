# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatus
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                                     :red_quantity, :visit_percent, :site_percent)

          def initialize(filter)
            @model = ::HouseStatus
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            house_statuses = apply_filters

            house_quantity = house_statuses.count
            visit_quantity = house_statuses.where.not(date: nil).count

            green_quantity = house_statuses.where(infected_containers: 0).count
            orange_quantity = house_statuses.where("infected_containers > 0 AND infected_containers <= 5").count
            red_quantity = house_statuses.where("infected_containers > 5").count

            visit_percent = visit_quantity.to_f / house_quantity * 100
            site_percent = (green_quantity + orange_quantity + red_quantity).to_f / house_quantity * 100

            StatusResults.new(
              house_quantity,
              visit_quantity,
              green_quantity,
              orange_quantity,
              red_quantity,
              visit_percent,
              site_percent
            )
          end

          private

          def apply_filters
            statuses = @model.all

            statuses
          end
        end
      end
    end
  end
end

