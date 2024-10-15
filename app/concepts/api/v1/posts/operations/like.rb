# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Operations
        class Like < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_post
          step :process_like_or_dislike

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def find_post
            @ctx[:data] = Post.find_by(id: @params[:id])
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
            end
          end

          def process_like_or_dislike
            like = @ctx[:data].likes.find_by(user_account: @current_user)
            if like
              like.destroy
            else
              @ctx[:data].likes.create(user_account: @current_user)
            end
            @ctx[:data].instance_variable_set(:@current_user_id, @current_user.id)
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
