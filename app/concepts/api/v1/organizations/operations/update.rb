# frozen_string_literal: true

module Api
  module V1
    module Organizations
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
            @ctx['contract.default'] = Api::V1::Organizations::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Organization.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            @ctx['contract.default'].errors.add(:base, I18n.t('errors.session.deactivated'))
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_organization
            begin
              @ctx[:model].update(@ctx['contract.default'].values.data)
              Success({ ctx: @ctx, type: :success })
            rescue StandardError
              add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                         custom_predicate: :not_found?)
              Failure({ ctx: @ctx, type: :invalid, model: true })
            end
          end
        end
      end
    end
  end
end
