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
            @model.then { |relation| wedge_clause(relation) }
                  .then { |relation| wedge_name_clause(relation) }
                  .then { |relation| team_clause(relation) }
                  .then { |relation| name_clause(relation) }
                  .then { |relation| user_profile_clause(relation) }
                  .then { |relation| type_clause(relation) }
                  .then { |relation| sort_clause(relation) }
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

          def type_clause(relation)
            return relation if @filter.nil? || @filter[:type].blank?

            relation.where(block_type: @filter[:type])
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            @sort[:field] = 'neighborhood_id' if @sort[:field] == 'sector'
            @sort[:field] = 'cities.name' if @sort[:field] == 'city'
            @sort[:field] = 'wedges.id' if @sort[:field] == 'wedge'
            @sort[:field] = 'organizations.name' if @sort[:field] == 'organization'
            @sort[:field] = 'teams.name' if @sort[:field] == 'name'
            @sort[:field] = "house_blocks.block_type" if @sort[:field] == 'type'
            @sort[:field] = "house_blocks.name" if @sort[:field] == 'name'

            sort_by_table_columns(relation) if @sort[:field]
          end
        end
      end
    end
  end
end
