# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Queries
        class HouseBlockList
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, params)
            @model = Wedge.includes(:neighborhoods, { house_blocks: :neighborhood })
            @filter = filter
            @sort = sort
            @params = params
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:wedge_id))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :neighborhoods, :filter, :sort

          def wedge_id(relation)
            return relation if @filter.nil? || @filter[:wedge_id].nil? || @filter[:wedge_id].blank?

            relation.find_by(id: filter[:wedge_id])
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
