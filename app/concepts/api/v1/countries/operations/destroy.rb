# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Operations
        class Destroy <  ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :model
          step :discard_countries

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Countries::Contracts::Destroy.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end


          def model
            @ctx[:model] = Country.kept.where(id: @ctx['contract.default']['country_ids'])
          end

          def discard_countries
            ActiveRecord::Base.transaction do
              @ctx[:model].discard_all
              Success({ ctx: @ctx, type: :success })
            end
          rescue StandardError => e
            Failure({ ctx: @ctx, type: :invalid })
          end

        end
      end
    end
  end
end
