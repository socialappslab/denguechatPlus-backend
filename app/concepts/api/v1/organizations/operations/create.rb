# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_organization

          def params(input)
            @ctx = {}
            @params = input.fetch(:params)
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Organizations::Contracts::Create.new(@params)
            @ctx['contract.default'].validate(@params)
            is_valid = @ctx['contract.default'].valid?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_organization
            begin
              @ctx[:model] = Organization.create(@ctx['contract.default'].model[:organization])
              return Success({ ctx: @ctx, type: :created })
            rescue => error
              @ctx['contract.default'].errors.add(:base, I18n.t('errors.session.deactivated'))
              return Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
            end
          end
        end
      end
    end
  end
end
