# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_city
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Cities::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = City.kept.find_by(id: @params[:id], state_id: @params[:state_id], country_id: @params[:country_id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            ErrorFormater.new_error(@ctx['contract.default'].errors,nil, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_neighborhoods
            neighborhood_ids = @ctx['contract.default'].values.data[:neighborhoods_attributes].pluck(:_destroy)
            city_id = @ctx['contract.default'].values.data[:id]
            Neighborhood.where(city_id: city_id, id: neighborhood_ids).discard_all
          end

          def update_city
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                update_neighborhoods
                Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => invalid
                 ErrorFormater.new_error(@ctx['contract.default'].errors,nil, I18n.t('errors.users.not_found'),
                           custom_predicate: :not_found?)
                Failure({ ctx: @ctx, type: :invalid, model: true })
                raise ActiveRecord::Rollback
              end
            end
          end

          def includes
            @ctx[:include] = ['neighborhoods']
          end

        end
      end
    end
  end
end
