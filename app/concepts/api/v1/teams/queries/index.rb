# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Team
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:sector_id_clause))
                  .yield_self(&method(:sector_name_clause))
                  .yield_self(&method(:wedge_id_clause))
                  .yield_self(&method(:wedge_name_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :teams, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('teams.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def sector_id_clause(relation)
            return relation if @filter.nil? || @filter[:sector_id].nil? || @filter[:sector_id].blank?

            relation.where(neighborhood_id: @filter[:sector_id])
          end

          def sector_name_clause(relation)
            return relation if @filter.nil? || @filter[:sector].blank?

            relation.joins(:sector).where('neighborhoods.name ILIKE ?', "%#{@filter[:sector]}%")
          end

          def wedge_id_clause(relation)
            return relation if @filter.nil? || @filter[:wedge_id].nil? || @filter[:wedge_id].blank?

            relation.where(wedge_id: @filter[:wedge_id])
          end

          def wedge_name_clause(relation)
            return relation if @filter.nil? || @filter[:wedge].blank?

            relation.joins(:wedge).where('wedges.name ILIKE ?', "%#{@filter[:wedge]}%")
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            @sort[:field] = 'neighborhood_id' if @sort[:field] == 'sector'
            sort_by_table_columns(relation) if @sort[:field]
          end
        end
      end
    end
  end
end
