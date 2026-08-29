# frozen_string_literal: true

module Api
  module V1
    module States
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = State
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :countries, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('States.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def sort_clause(relation)
            return relation unless @sort&.dig(:field) == 'states.name'

            sort_by_table_columns(relation)
          end
        end
      end
    end
  end
end
