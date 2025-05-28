# frozen_string_literal: true

module Api
  module V1
    module States
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_state
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::States::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = State.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_cities
            city_ids = @ctx['contract.default'].values.data[:cities_attributes].pluck(:_destroy)
            state_id = @ctx['contract.default'].values.data[:id]
            City.where(state_id: state_id, id: city_ids).discard_all
          end

          def update_state
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                update_cities
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
            @ctx[:include] = ['cities']
          end
        end
      end
    end
  end
end
