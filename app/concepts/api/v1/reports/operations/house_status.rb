# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Operations
        class HouseStatus < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :gather_information

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @source = input[:request].headers['source'] || 'brigade'
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Reports::Contracts::HouseStatus.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end


          def gather_information
            @ctx[:data] = if @source == 'visits'
                            Api::V1::Reports::Queries::HouseStatusWeb.call(@ctx['contract.default']['filter'], @current_user)
            else
              Api::V1::Reports::Queries::HouseStatusMobile.call(@ctx['contract.default']['filter'], @current_user)

                          end

            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
