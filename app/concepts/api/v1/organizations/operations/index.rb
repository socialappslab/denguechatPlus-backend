# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Operations
        class Index < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :cursor_and_paginate
          step :list
          tee :page_pagination?
          tee :meta

          def params(input)
            @ctx = {}
            @params = input.fetch(:params)
            @ctx['contract.paginate'] = @params[:page]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Organizations::Contracts::Index.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def cursor_and_paginate
            @ctx[:sort] = { field: 'organizations.name', direction: 'asc' }
          end

          def list
            @ctx[:data] = Api::V1::Organizations::Queries::Index.call(@ctx['contract.default']['filter'], @ctx[:sort])
            Success({ ctx: @ctx, type: :success })
          end

          def page_pagination?
            @params.dig(:page, :is_cursor)
          end

          def paginate
            @pagy = Api::V1::Lib::Paginates::Paginate.new(@ctx, @ctx[:data])
            Success({ ctx: @ctx, type: :success })
          end

          def meta
            @ctx[:meta] = {
              # total: @pagy.count,
              has_more: @pagy.try(:has_more)
            }
          end
        end
      end
    end
  end
end
