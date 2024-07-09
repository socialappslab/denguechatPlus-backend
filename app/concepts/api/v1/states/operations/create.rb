# frozen_string_literal: true

module Api
  module V1
    module States
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_state
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::States::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_state
            @ctx[:model] = State.create(@ctx['contract.default'].values.data)
            return Success({ ctx: @ctx, type: :created }) if @ctx[:model].persisted?

            Failure({ ctx: @ctx, type: :invalid, model: true })
          end

          def includes
            @ctx[:include] = %w[cities]
          end
        end
      end
    end
  end
end
