# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_neighborhood

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_neighborhood
            @ctx[:data] =
              Neighborhood.kept.find_by(id: @params[:id])
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
