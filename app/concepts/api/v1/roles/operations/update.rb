# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :retrieve_rol
          step :update_rol

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Roles::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def retrieve_rol
            @ctx[:model] = Role.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            ErrorFormater.new_error(
              custom_predicate: :not_found?
            )
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_rol
            ActiveRecord::Base.transaction do
              begin
                data_processed = @ctx['contract.default'].values.data
                @ctx[:model].update!(data_processed)
                next Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid
                errors = ErrorFormater.new_error(field: :base, msg: @ctx[:model].errors.full_messages.join(' '),
                                                 custom_predicate: :credentials_wrong?)
                Failure({ ctx: @ctx, type: :invalid, errors: errors })
              end
            end
          end
        end
      end
    end
  end
end
