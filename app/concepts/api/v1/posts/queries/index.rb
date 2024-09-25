# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, current_user, source)
            @model = Post
            @filter = filter
            @sort = sort
            @current_user = current_user
            @source = source
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:team_clause))
                  .yield_self(&method(:sector_id_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :posts, :filter, :sort

          def team_clause(relation)
            return relation if @source == 'web'
            return relation.where(city_id: @current_user.city_id) if @filter.nil? || @filter[:team_id].blank?

            relation.where(team_id: @filter[:team_id])
          end

          def sector_id_clause(relation)
            return relation if @source == 'mobile'
            return relation if @filter.nil? || @filter[:sector_id].blank?

            relation.where(neighborhood_id: @filter[:sector_id])
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            sort_by_table_columns(relation) if @sort[:field]
          end
        end
      end
    end
  end
end
