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
            @ctx['contract.default'] = Api::V1::Cities::Contracts::Update.kall(@params.to_h)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] =
              City.kept.find_by(id: @params[:id], state_id: @params[:state_id], country_id: @params[:country_id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            errors = ErrorFormater.new_error(field: :base, msg: @ctx['contract.default'].errors,
                                             custom_predicate: :not_found? )
            Failure({ ctx: @ctx, type: :invalid, errors:  }) unless @ctx[:model]
          end

          def update_neighborhoods
            neighborhood_ids = @ctx['contract.default'].values.data[:neighborhoods_attributes].pluck(:_destroy)
            city_id = @ctx['contract.default'].values.data[:id]
            Neighborhood.where(city_id: city_id, id: neighborhood_ids).discard_all
          end

          def update_city
            ActiveRecord::Base.transaction do
              begin
                data = @ctx['contract.default'].values.data
                if @ctx['contract.default'].values.data[:neighborhoods_attributes]
                  data[:neighborhoods_attributes].map do |obj_hash|
                    obj_hash[:state_id] = @ctx[:model].state_id
                    obj_hash[:country_id] = @ctx[:model].country_id
                  end
                end
                @ctx[:model].update!(data)
                update_neighborhoods  if @ctx['contract.default'].values.data[:neighborhoods_attributes]
                Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => invalid
                errors = ErrorFormater.new_error(field: :base, msg: @ctx[:model].errors.full_messages,
                                                 custom_predicate: :not_found? )
                Failure({ ctx: @ctx, type: :invalid, errors: })
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
