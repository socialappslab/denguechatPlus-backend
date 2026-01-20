# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Queries
        class ContainerTypesInspectedChart
          def initialize(wedge_id, from:, to:)
            @wedge_id = wedge_id
            @from = from
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            raw_data = ContainerTypesInspected.call(@wedge_id, from: @from, to: @to)

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
