# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Queries
        class Show
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(params)
            includes = %i[breeding_site_type elimination_method_type water_source_types container_protections inspection_type_contents]
            @model = Inspection.includes(*includes)
            @visit_id = params[:id]
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.find_by(id: @visit_id)
          end

          private

          attr_reader :visit_id
        end
      end
    end
  end
end
