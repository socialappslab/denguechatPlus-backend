# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, params)
            @model = Wedge.includes(:neighborhoods)
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
                  .yield_self(&method(:neighborhood_clause))
                  .yield_self(&method(:sector_id_clause))
                  .yield_self(&method(:sector_name))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :neighborhoods, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            word_searched = CGI.unescape(@filter[:name])

            relation.where('wedges.name ilike :query', query: "%#{word_searched}%")
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

          def neighborhood_clause(relation)
            return relation if @params['neighborhood_id'].nil? || @params['neighborhood_id'].blank?

            relation.joins(:neighborhoods).where(neighborhoods: { id: @params['neighborhood_id'] })
          end

          def sector_id_clause(relation)
            return relation if @filter.nil? || @filter[:sector_id].nil? || @filter[:sector_id].blank?

            relation.joins(:neighborhoods).where(neighborhoods: { id: @filter[:sector_id] })
          end

          def sector_name(relation)
            return relation if @filter.nil? || @filter[:sector_name].blank?

            word_searched = CGI.unescape(@filter[:sector_name])

            relation.joins(:neighborhoods).where('neighborhoods.name ilike :query', query: "%#{word_searched}%")
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
