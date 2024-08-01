# frozen_string_literal: true

module Api
  module V1
    module Permissions
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_permission

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_permission
            @ctx[:data] = Permission.find_by(id: @params[:id])
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
            end
          end
        end
      end
    end
  end
end
