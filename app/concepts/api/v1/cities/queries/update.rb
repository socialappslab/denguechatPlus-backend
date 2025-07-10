# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Queries
        class Update
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(_filter, _sort)
            @model = City
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:name_clause))
          end

          private

          attr_reader :cities, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('Cities.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            case @sort[:field]
            when 'name', 'status' then sort_by_status_and_name(relation, :Cities)
            when 'Cities.name' then sort_by_table_columns(relation)
            else relation
            end
          end
        end
      end
    end
  end
end
