# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_city
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_city
            @ctx[:data] = City.find_by(id: @params[:id], country_id: @params['country_id'], state_id: @params['state_id'],  discarded_at: nil)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
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
