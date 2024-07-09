# frozen_string_literal: true

module Api
  module V1
    module States
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_state
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_state
            @ctx[:data] = State.find_by(id: @params[:id], discarded_at: nil)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
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
