# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatus
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                                     :red_quantity, :visit_percent, :site_percent)

          def initialize(filter, current_user)
            @model = ::HouseStatus
            @filter = filter
            @current_user = current_user
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

            visit_percent = house_quantity.zero? ? 0 : visit_quantity.to_f / house_quantity * 100
            site_percent = house_quantity.zero? ? 0 : (green_quantity + orange_quantity + red_quantity).to_f / house_quantity * 100

            visit_percent = visit_quantity.to_f / house_quantity * 100
            site_percent = (green_quantity + orange_quantity + red_quantity).to_f / house_quantity * 100

            visit_percent = visit_percent.nan? ? 0 : visit_quantity
            site_percent = site_percent.nan? ? 0 : site_percent

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
            @filter ||= {}
            team_id = @filter[:team_id]
            team_id = team_id.nil? ? @current_user&.teams&.first&.id : team_id
            @model.where(team_id:) || @model.all
          end
        end
      end
    end
  end
end

