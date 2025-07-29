# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = HouseBlock.includes(:neighborhood, :wedges, :houses, :brigadists)
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

            relation.joins(:wedges).where(wedges: { id: @filter[:wedge_id] })
          end

          def team_clause(relation)
            return relation if @filter.nil? || @filter[:team_id].blank?

            team = Team.find_by(id: @filter[:team_id])

            relation.joins(:houses)
                    .where(houses: { neighborhood_id: team&.neighborhood_id })
                    .joins(:wedges)
                    .where(wedges: { id: team&.wedge_id })
                    .distinct
          end

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            word_searched = CGI.unescape(@filter[:name])
            relation.where('house_blocks.name ILIKE ?', "%#{word_searched}%")
          end

          def wedge_name_clause(relation)
            return relation if @filter.nil? || @filter[:wedge].blank?

            word_searched = CGI.unescape(@filter[:wedge])
            relation.joins(:wedges)
                    .where('wedges.name ILIKE ?', "%#{word_searched}%")
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
