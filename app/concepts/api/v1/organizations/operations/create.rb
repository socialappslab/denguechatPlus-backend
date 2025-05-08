# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_organization

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Organizations::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_organization
            begin
              @ctx[:model] = Organization.create(@ctx['contract.default'].values.data)
              Success({ ctx: @ctx, type: :created })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end
        end
      end
    end
  end
end
