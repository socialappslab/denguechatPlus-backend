# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class HouseStatusWeb
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                                     :red_quantity, :visit_percent, :site_percent)

          def initialize(filter)
            @model = ::HouseStatus
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:house_block))
                  .yield_self(&method(:wedge))
                  .yield_self(&method(:neighborhood))
                  .yield_self(&method(:city))
                  .yield_self(&method(:country))
                  .yield_self(&method(:reference_code))


          end

          private

          attr_reader :countries, :filter, :sort

          def house_block(relation)
            return relation if @filter.nil? || @filter[:house_block_id].blank?

            relation.where(house_block_id: @filter[:house_block_id])
          end

          def wedge(relation)
            return relation if @filter.nil? || @filter[:wedge_id].blank?

            relation.where(wedge_id: @filter[:wedge_id])
          end

          def neighborhood(relation)
            return relation if @filter.nil? || @filter[:neighborhood_id].blank?

            relation.where(neighborhood_id: @filter[:neighborhood_id])
          end

          def city(relation)
            return relation if @filter.nil? || @filter[:city_id].blank?

            relation.where(city_id: @filter[:city_id])
          end

          def country(relation)
            return relation if @filter.nil? || @filter[:country_id].blank?

            relation.where(country_id: @filter[:country_id])
          end

          def reference_code(relation)
            return relation if @filter.nil? || @filter[:reference_code].blank?

            relation.where(reference_code: @filter[:reference_code])
          end

        end
      end
    end
  end
end
