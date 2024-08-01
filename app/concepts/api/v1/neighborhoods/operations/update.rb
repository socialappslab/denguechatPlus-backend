# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_neighborhood

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Neighborhoods::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Neighborhood.find_by(id: @params[:id], country_id: @params['country_id'], state_id: @params['state_id'],
                                                city_id: @params['city_id'],  discarded_at: nil)
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            ErrorFormater.new_error(field: :base, msg: 'not found', custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_neighborhood
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => error
                errors = ErrorFormater.new_error(field: :base, msg: error,
                                                 custom_predicate: :user_account_without_confirmation?)
                Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]

                raise ActiveRecord::Rollback
              end
            end
          end

        end
      end
    end
  end
end
