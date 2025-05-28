# frozen_string_literal: true

module Api
  module V1
    module Points
      module Operations
        class AccumulatedPoints < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :cursor_and_paginate
          step :list

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Points::Contracts::AccumulatedPoints.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def cursor_and_paginate
            @ctx[:sort] = { field: 'points.created_at', direction: 'desc' } if @params['sort'].nil?
            direction = @params['order'].nil? ? 'desc' : @params['order']
            @ctx[:sort] = { field: @params['sort'], direction: } if @params['sort']
          end

          def list
            @ctx[:data] = Api::V1::Points::Queries::AccumulatedPoints.call(@ctx['contract.default']['filter'], @ctx[:sort])[0]
            Success({ ctx: @ctx, type: :success })
          end

        end
      end
    end
  end
end
