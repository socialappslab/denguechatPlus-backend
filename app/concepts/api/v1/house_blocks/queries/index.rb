# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = HouseBlock.includes(:neighborhood, :wedge)
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:wedge_clause))
                  .yield_self(&method(:wedge_name_clause))
                  .yield_self(&method(:team_clause))
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:user_profile_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :houses, :filter, :sort

          def wedge_clause(relation)
            return relation if @filter.nil? || @filter[:wedge_id].blank?

            relation.where(wedge_id: @filter[:wedge_id])
          end

          def team_clause(relation)
            return relation if @filter.nil? || @filter[:team_id].blank?

            team = Team.find_by(id: @filter[:team_id])
            return relation unless team

            wedge_id = team.wedge_id
            return relation unless wedge_id

            neighborhood_id = team.neighborhood_id
            return relation unless neighborhood_id

            relation.joins(:houses).where(houses: { neighborhood_id: neighborhood_id, wedge_id: wedge_id }).distinct
          end

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('house_blocks.name ilike :query', query: "%#{@filter[:name]}%")
          end


          def wedge_name_clause(relation)
            return relation if @filter.nil? || @filter[:wedge].blank?

            relation.joins(:wedge).where('wedges.name ilike :query', query: "%#{@filter[:wedge]}%")
          end

          def user_profile_clause(relation)
            return relation if @filter.nil? || @filter[:user_profile_id].blank?

            relation.where(user_profile_id: @filter[:user_profile_id])
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
