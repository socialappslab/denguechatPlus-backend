# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Operations
        class Destroy <  ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :model
          step :discard_special_places

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::SpecialPlaces::Contracts::Destroy.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end


          def model
            @ctx[:model] = SpecialPlace.kept.where(id: @ctx['contract.default']['special_place_ids'])
          end

          def discard_special_places
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
