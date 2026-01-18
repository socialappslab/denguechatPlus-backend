# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class ContainerPositivesChart
          def initialize(team_id, from:, to:)
            @team_id = team_id
            @from = from
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            raw_data = ContainerPositives.call(@team_id, from: @from, to: @to)

            raw_data.map do |item|
              {
                value: item[:count],
                name_es: item[:name_es],
                name_en: item[:name_en],
                name_pt: item[:name_pt],
                breeding_site_type_id: item[:breeding_site_type_id]
              }
            end
          end
        end
      end
    end
  end
end
