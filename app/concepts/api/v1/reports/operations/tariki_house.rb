# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Operations
        class TarikiHouse < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :gather_information

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @source = input[:request].headers['source']
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Reports::Contracts::TarikiHouse.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def gather_information
            @ctx[:data] =
              Api::V1::Reports::Queries::TarikiHouse.call(@ctx['contract.default']['filter'], @current_user)

            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
