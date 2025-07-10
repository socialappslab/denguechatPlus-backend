# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Queries
        class ListByCountryAndStateAssumption
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, params)
            @model = City
            @filter = filter
            @sort = sort
            @params = params
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.kept
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:country_clause))
                  .yield_self(&method(:state_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :cities, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('cities.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def country_clause(relation)
            country_id = Country.find_by(name: 'Peru')&.id || @params[:country_id]
            return relation if country_id.nil?

            relation.where(cities: { country_id: country_id })
          end

          def state_clause(relation)
            state_id = State.find_by(name: 'Loreto')&.id || @params['state_id']
            return relation if state_id.nil?

            relation.where(cities: { state_id: state_id })
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            case @sort[:field]
            when 'name', 'status' then sort_by_status_and_name(relation, :cities)
            when 'Cities.name' then sort_by_table_columns(relation)
            else relation
            end
          end
        end
      end
    end
  end
end
