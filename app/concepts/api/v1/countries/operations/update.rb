# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_organization
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Countries::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Country.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_states
            state_ids = @ctx['contract.default'].values.data[:states_attributes].pluck(:_destroy)
            country_id = @ctx['contract.default'].values.data[:id]
            State.where(country_id: country_id, id: state_ids).discard_all
          end

          def update_organization
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                update_states
                return Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid
                add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                           custom_predicate: :not_found?)
                Failure({ ctx: @ctx, type: :invalid, model: true })
                raise ActiveRecord::Rollback
              end
            end
          end

          def includes
            @ctx[:include] = ['states']
          end
        end
      end
    end
  end
end
