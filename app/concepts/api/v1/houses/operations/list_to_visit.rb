# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Operations
        class ListToVisit < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :cursor_and_paginate
          step :list
          tee :page_pagination?
          tee :paginate
          tee :meta

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @user_account = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Houses::Contracts::ListToVisit.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def cursor_and_paginate
            @ctx[:sort] = { field: 'houses.id', direction: 'desc' } if @params['sort'].nil?
            direction = @params['order'].nil? ? 'asc' : @params['order']
            @ctx[:sort] = { field: @params['sort'], direction: } if @params['sort']
          end

          def list
            @ctx[:data] = Api::V1::Houses::Queries::ListToVisit.call(@user_account, @ctx['contract.default']['filter'])
            Success({ ctx: @ctx, type: :success })
          end

          def page_pagination?
            @params.dig(:page, :is_cursor)
          end

          def paginate
            @params['page'] = { 'number' => '1', 'size' => '1000000' }
            @pagy = Api::V1::Lib::Paginates::Paginate.kall(ctx: @ctx, model: @ctx[:data], params: @params.slice('page'))
            Success({ ctx: @ctx, type: :success })
          end

          def meta
            @ctx[:meta] = {
              total: @ctx[:pagy].count
            }
          end
        end
      end
    end
  end
end
