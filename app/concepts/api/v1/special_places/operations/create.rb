# frozen_string_literal: true
#  def self.policy(options, action, authorize: [], model: nil, with: nil)
module Api
  module V1
    module SpecialPlaces
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_special_place

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::SpecialPlaces::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_special_place
            begin
              @ctx[:model] = SpecialPlace.create(@ctx['contract.default'].values.data)
              return Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :user_account_without_confirmation? )

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end
        end
      end
    end
  end
end
