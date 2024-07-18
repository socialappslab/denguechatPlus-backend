# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_team
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_team
            @ctx[:data] = Team.find_by(id: @params[:id], deleted_at: nil)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
            end
          end

          def includes
            @ctx[:include] = ['user_profiles']
          end
        end
      end
    end
  end
end
