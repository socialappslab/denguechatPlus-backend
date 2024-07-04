# frozen_string_literal: true

module Api
  module V1
    module Locations
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter)
            @model = Country
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:id_clause))
          end

          private

          attr_reader :organizations, :filter

          def id_clause(relation)
            return relation if @filter.nil? || @filter[:country_id].blank?

            relation.where(country: { id: @filter[:country_id] })
          end

        end
      end
    end
  end
end
