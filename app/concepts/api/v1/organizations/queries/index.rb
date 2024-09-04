# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Organization
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.kept
                  .yield_self(&method(:status_clause))
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :organizations, :filter, :sort

          def status_clause(relation)
            return active_organizations(relation) if @filter.nil? || @filter[:status].blank?

            case @filter[:status]
            when 'all'
              all_organizations(relation)
            when 'active'
              active_organizations(relation)
            when 'inactive'
              inactive_organizations(relation)
            else
              active_organizations(relation)
            end
          end

          def active_organizations(relation)
            relation.where(discarded_at: nil)
          end

          def inactive_organizations(relation)
            relation.where.not(discarded_at: nil)
          end

          def all_organizations(relation)
            relation.all
          end

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('organizations.name ilike :query', query: "%#{@filter[:name]}%")
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
