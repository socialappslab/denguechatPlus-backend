# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_wedge

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_wedge
            @ctx[:data] =
              Wedge.find_by(id: @params[:id], country_id: @params['country_id'], state_id: @params['state_id'],
                                   city_id: @params['city_id'],  discarded_at: nil)
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
