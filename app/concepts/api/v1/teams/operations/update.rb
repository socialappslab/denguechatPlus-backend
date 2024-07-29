# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_organization

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Teams::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Team.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            errors = ErrorFormater.new_error(field: :base, msg: 'Team not found', custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
          end

          def update_organization
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                return Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => invalid
                add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                           custom_predicate: :not_found?)
                Failure({ ctx: @ctx, type: :invalid, model: true })
                raise ActiveRecord::Rollback
              end
            end
          end

        end
      end
    end
  end
end
