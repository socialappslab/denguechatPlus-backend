# frozen_string_literal: true

module Api
  module V1
    module Posts
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
            @source = input[:request].headers['source'] || 'mobile'
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Posts::Contracts::Index.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def cursor_and_paginate
            @ctx[:sort] = { field: 'posts.created_at', direction: 'desc' } if @params['sort'].nil?
            direction = @params['order'].nil? ? 'desc' : @params['order']
            @ctx[:sort] = { field: @params['sort'], direction: } if @params['sort']
          end

          def list
            @ctx[:data] = Api::V1::Posts::Queries::Index.call(@ctx['contract.default']['filter'], @ctx[:sort], @current_user, @source)
            Success({ ctx: @ctx, type: :success })
          end

          def page_pagination?
            @params.dig(:page, :is_cursor)
          end

          def paginate
            page = {"page"=>{"number"=>"1", "size"=>"10"}} if @params['page'].nil?
            @params[:page] = {} unless  @params['page']
            @params['page']['size'] = 1 unless @params['page']
            @params['page']['number'] = 1 unless @params['page'][:number]
            page = @params.slice("page")
            @pagy = Api::V1::Lib::Paginates::Paginate.kall(ctx: @ctx, model: @ctx[:data], params: page)
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
