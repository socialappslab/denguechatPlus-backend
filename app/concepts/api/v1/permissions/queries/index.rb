# frozen_string_literal: true

module Api
  module V1
    module Permissions
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Permission
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            #
            @model.yield_self(&method(:name))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :permissions, :filter, :sort

          def active_records(relation)
            relation.where(discarded_at: nil)
          end

          def name(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('permissions.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def resource(relation)
            return relation if @filter.nil? || @filter[:resource].blank?

            relation.where('permissions.resource ilike :query', query: "%#{@filter[:resource]}%")
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            lower_case = %w[permissions.name permissions.resource].include? @sort[:field]
            sort_by_table_columns(relation, lower_case:)
          end
        end
      end
    end
  end
end
