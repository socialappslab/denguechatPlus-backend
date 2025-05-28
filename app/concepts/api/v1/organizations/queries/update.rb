# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Queries
        class Update
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Organization
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.where(discarded_at: nil)
                  .yield_self(&method(:name_clause))
          end

          private

          attr_reader :organizations, :filter, :sort

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('organizations.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            case @sort[:field]
            when 'name', 'status' then sort_by_status_and_name(relation, :organizations)
            when 'organizations.name' then sort_by_table_columns(relation)
            else relation
            end
          end
        end
      end
    end
  end
end
