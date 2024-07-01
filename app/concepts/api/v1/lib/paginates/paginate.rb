# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Paginates
        class Paginate
          def initialize(ctx, model)
            @ctx = ctx
            @model = model
            pagy
          end

          def pagy
            @ctx[:pagy], @ctx[:model] = Services::Pagy.call(
              @model,
              page: @ctx['contract.paginate'].page.number,
              items: @ctx['contract.paginate'].page.size,
              count: @ctx[:custom_count]
            )
          end

          def valid_page?
            !pagy.overflow?
          end

          def assign_paginate_errors(ctx, **)
            @ctx['contract.default'].merge!(ctx['contract.paginate'].errors.messages)
          end
        end
      end
    end
  end
end
