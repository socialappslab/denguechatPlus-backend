# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = SpecialPlace
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:status_clause))
                  .yield_self(&method(:name_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :special_places, :filter, :sort

          def status_clause(relation)
            return active_special_places(relation) if @filter.nil? || @filter[:status].blank?

            case @filter[:status]
            when 'all'
              all_special_places(relation)
            when 'active'
              active_special_places(relation)
            when 'inactive'
              inactive_special_places(relation)
            else
              active_special_places(relation)
            end
          end

          def active_special_places(relation)
            relation.where(discarded_at: nil)
          end

          def inactive_special_places(relation)
            relation.where.not(discarded_at: nil)
          end

          def all_special_places(relation)
            relation.all
          end

          def name_clause(relation)
            return relation if @filter.nil? || @filter[:name].blank?

            relation.where('special_places.name ilike :query', query: "%#{@filter[:name]}%")
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
