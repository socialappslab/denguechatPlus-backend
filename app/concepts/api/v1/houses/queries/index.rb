# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Queries
        class Index
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
            @model.yield_self(&method(:status_clause))
                  .yield_self(&method(:reference_code_clause))
                  .yield_self(&method(:house_block_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :houses, :filter, :sort

          def status_clause(relation)
            return active_houses(relation) if @filter.nil? || @filter[:status].blank?

            case @filter[:status]
            when 'all'
              all_houses(relation)
            when 'active'
              active_houses(relation)
            when 'inactive'
              inactive_houses(relation)
            else
              active_houses(relation)
            end
          end

          def active_houses(relation)
            relation.where(discarded_at: nil)
          end

          def inactive_houses(relation)
            relation.where.not(discarded_at: nil)
          end

          def all_houses(relation)
            relation.all
          end

          def reference_code_clause(relation)
            return relation if @filter.nil? || @filter[:reference_code].blank?

            relation.where('houses.reference_code ILIKE ?', "%#{@filter[:reference_code]}%")
          end

          def house_block_clause(relation)
            return relation if @filter.nil? || @filter[:house_block_id].blank?

            relation.where('houses.house_block_id = :query', query: @filter[:house_block_id])
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
