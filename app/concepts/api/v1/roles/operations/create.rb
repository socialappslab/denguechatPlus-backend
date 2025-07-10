# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_role

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Roles::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_role
            @ctx[:model] = Role.create(@ctx['contract.default'].values.data)
            return Success({ ctx: @ctx, type: :created }) if @ctx[:model].persisted?

            Failure({ ctx: @ctx, type: :invalid, model: true })
          end
        end
      end
    end
  end
end
