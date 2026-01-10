# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class ContainerPositives
          def initialize(team_id, from:, to:)
            @team_id = team_id
            @from = from
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            results = BreedingSiteType.kept.map do |breeding_site_type|
              {
                breeding_site_type_id: breeding_site_type.id,
                name_es: breeding_site_type.name_es,
                name_en: breeding_site_type.name_en,
                name_pt: breeding_site_type.name_pt,
                count: count_positives_for(breeding_site_type.id)
              }
            end
            results.sort_by { |item| -item[:count] }
          end

          private

          def inspection_scope
            scope = Inspection.joins(:visit).where(visits: { team_id: @team_id })
            scope = scope.where(inspections: { created_at: @from.beginning_of_day.. }) if @from
            scope.where(inspections: { created_at: ..@to.end_of_day })
          end

          def count_positives_for(breeding_site_type_id)
            inspection_scope
              .where(breeding_site_type_id: breeding_site_type_id)
              .where(color: %w[yellow red])
              .count
          end
        end
      end
    end
  end
end
