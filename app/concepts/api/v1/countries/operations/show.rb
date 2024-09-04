# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_country

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_country
            @ctx[:data] = Country.find_by(id: @params[:id], discarded_at: nil)
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
