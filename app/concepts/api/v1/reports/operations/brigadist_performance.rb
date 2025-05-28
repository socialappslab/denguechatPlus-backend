# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Operations
        class BrigadistPerformance < ApplicationOperation
          include Dry::Transaction

          Result = Struct.new(:visit_rank, :green_house_rank)

          tee :params
          step :validate_schema
          step :gather_information

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Reports::Contracts::BrigadistPerformance.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end


          def gather_information
            #@ctx[:data][:visits_rank] = Api::V1::Reports::Queries::BrigadistPerformance.call(@ctx['contract.default']['filter'])
            #@ctx[:data][:green_houses_rank] = Api::V1::Reports::Queries::BrigadistPerformanceGreenHouses.call(@ctx['contract.default']['filter'])
            @ctx[:data] =  Result.new(Api::V1::Reports::Queries::BrigadistPerformance.call(@ctx['contract.default']['filter']),
                       Api::V1::Reports::Queries::BrigadistPerformanceGreenHouses.call(@ctx['contract.default']['filter']))

            Success({ ctx: @ctx, type: :success })

          end
        end
      end
    end
  end
end
