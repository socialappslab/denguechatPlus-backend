# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Role.includes(:permissions)
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:name))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :roles, :filter, :sort

          def active_records(relation)
            relation.where(discarded_at: nil)
          end

          def name(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('roles.name ilike :query', query: "%#{@filter[:name]}%")
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            sort_by_table_columns(relation)
          end
        end
      end
    end
  end
end
