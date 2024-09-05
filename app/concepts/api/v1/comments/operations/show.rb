# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_comment

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_comment
            @ctx[:data] = Comment.find_by(id: @params[:id])
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
