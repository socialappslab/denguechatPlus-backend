# frozen_string_literal: true

module Api
  module V1
    module GetAddress
      module Operations
        class FindAddress < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :list

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::GetAddress::Contracts::FindAddress.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def list
            lat = @ctx['contract.default']['latitude']
            lon = @ctx['contract.default']['longitude']
            result = Geocoder.search([lat, lon])
            @ctx[:data] = Api::V1::GetAddress::Decorators::AddressDecorator.call(result)
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
