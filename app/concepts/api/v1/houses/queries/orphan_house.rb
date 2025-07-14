# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Queries
        class OrphanHouse
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = House
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:active_houses))
                  .yield_self(&method(:assignment_status))
                  .yield_self(&method(:country_id))
                  .yield_self(&method(:state_id))
                  .yield_self(&method(:neighborhood_id))
                  .yield_self(&method(:wedge_id))
                  .yield_self(&method(:house_block_id))
                  .yield_self(&method(:reference_code))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :houses, :filter, :sort

          def active_houses(relation)
            relation.where(discarded_at: nil)
          end

          def assignment_status(relation)
            relation.where(assignment_status: 0)
          end

          def country_id(relation)
            return relation if @filter.nil? || @filter[:country_id].blank?

            relation.where(country_id: @filter[:country_id])
          end

          def state_id(relation)
            return relation if @filter.nil? || @filter[:state_id].blank?

            relation.where(state_id: @filter[:state_id])
          end

          def neighborhood_id(relation)
            return relation if @filter.nil? || @filter[:neighborhood_id].blank?

            relation.where(neighborhood_id: @filter[:neighborhood_id])
          end

          def house_block_id(relation)
            return relation if @filter.nil? || @filter[:house_block_id].blank?

            relation.where(house_block_id: @filter[:house_block_id])
          end

          def wedge_id(relation)
            return relation if @filter.nil? || @filter[:wedge_id].blank?

            relation.where(wedge_id: @filter[:wedge_id])
          end

          def reference_code(relation)
            return relation if @filter.nil? || @filter[:reference_code].blank?

            relation.where('houses.reference_code = :query', query: @filter[:reference_code])
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
