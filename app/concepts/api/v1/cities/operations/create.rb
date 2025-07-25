# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_city
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Cities::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_city
            data = @ctx['contract.default'].values.data
            if @ctx['contract.default'].values.data[:neighborhoods_attributes]
              data[:neighborhoods_attributes].map do |obj_hash|
                obj_hash[:state_id] = @params[:state_id]
                obj_hash[:country_id] = @params[:country_id]
              end
            end
            @ctx[:model] = City.create(data)
            return Success({ ctx: @ctx, type: :created }) if @ctx[:model].persisted?

            errors = ErrorFormater.new_error(field: :base, msg: @ctx[:model].errors.full_messages,
                                             custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, errors: })
          end

          def includes
            @ctx[:include] = %w[neighborhoods]
          end
        end
      end
    end
  end
end
