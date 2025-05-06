# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(params, sort)
            includes = %i[breeding_site_type elimination_method_type water_source_types container_protections inspection_type_contents]
            @model = Inspection.includes(*includes)
            @params = params || {}
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model
              .yield_self(&method(:by_visit))
              .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :sort

          def by_visit(relation)
            return relation if @params[:visit_id].blank?

            relation.where(visit_id: @params[:visit_id])
          end

          def sort_clause(relation)
            return relation if sort.blank? || sort[:field].blank?

            direction = sort[:direction].presence_in(%w[asc desc]) || 'asc'
            relation.order("#{sort[:field]} #{direction}")
          end
        end
      end
    end
  end
end
