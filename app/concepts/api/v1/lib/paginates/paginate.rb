# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Paginates
        class Paginate
          def self.kall(...)
            new(...).call
          end

          def initialize(ctx:, model:, params:)
            @ctx = ctx
            @model = model
            @params = params
            @ctx['contract.paginate'] = validate
          end

          def call
            pagy_paginate
            valid_page?
          end

          def validate
            Api::V1::Lib::Paginates::Contract.kall(@params)
          end

          def pagy_paginate
            @ctx[:pagy], @ctx[:model] = Services::Pagy.call(
              @model,
              page: number_per_page,
              items: size_per_page,
              count: @ctx[:custom_count]
            )
          end

          def valid_page?
            @ctx[:pagy].overflow?
          end

          def assign_paginate_errors(ctx, **)
            @ctx['contract.default'].merge!(ctx['contract.paginate'].errors.messages)
          end

          private

          def number_per_page
            return 1 unless @ctx['contract.paginate'].success?

            @ctx['contract.paginate']['page'][:number]
          end

          def size_per_page
            return 20 unless @ctx['contract.paginate'].success?

            @ctx['contract.paginate']['page'][:size]
          end
        end
      end
    end
  end
end
