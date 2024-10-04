# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_post

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def find_post
            @ctx[:data] = Api::V1::Posts::Queries::Show.call(@current_user, @source, @params)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              @ctx[:data].instance_variable_set(:@current_user_idx, @current_user.id)
              Success({ ctx: @ctx, type: :success })
            end
          end
        end
      end
    end
  end
end
