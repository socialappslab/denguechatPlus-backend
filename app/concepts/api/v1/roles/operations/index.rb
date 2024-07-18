# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Operations
        class Index < ApplicationOperation
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
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Roles::Contracts::Index.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def cursor_and_paginate
            @ctx[:sort] = { field: @params['sort'], direction: @params['order'] }
          end

          def list
            @ctx[:data] = Api::V1::Roles::Queries::Index.call(@ctx['contract.default']['filter'], @ctx[:sort])
            Success({ ctx: @ctx, type: :success })
          end

          def page_pagination?
            @params.dig(:page, :is_cursor)
          end

          def paginate
            @pagy = Api::V1::Lib::Paginates::Paginate.kall(ctx: @ctx, model: @ctx[:data], params: @params.slice("page"))
            Success({ ctx: @ctx, type: :success })
          end

          def includes
            @ctx[:include] = ['permissions']
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
