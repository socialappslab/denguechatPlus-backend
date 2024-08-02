# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, params)
            @model = Neighborhood
            @filter = filter
            @sort = sort
            @params = params
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:country_clause))
                  .yield_self(&method(:state_clause))
                  .yield_self(&method(:city_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :neighborhoods, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('neighborhoods.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def country_clause(relation)
            return relation if @params['country_id'].nil? || @params['country_id'].blank?

            relation.where(neighborhoods: { country_id: @params['country_id'] })
          end

          def state_clause(relation)
            return relation if @params['state_id'].nil? || @params['state_id'].blank?

            relation.where(neighborhoods: { state_id: @params['state_id'] })
          end

          def city_clause(relation)
            return relation if @params['city_id'].nil? || @params['city_id'].blank?

            relation.where(neighborhoods: { state_id: @params['city_id'] })
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            case @sort[:field]
            when 'name', 'status' then sort_by_status_and_name(relation, :neighborhoods)
            when 'neighborhoods.name' then sort_by_table_columns(relation)
            else relation
            end
          end
        end
      end
    end
  end
end