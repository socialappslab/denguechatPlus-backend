# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Operations
        class Destroy < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :retrieve_post
          step :authorized_user?
          step :delete_post

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Posts::Contracts::Destroy.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            return Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def retrieve_post
            @ctx[:model] = Post.find_by(id: @params[:id])
          end

          def authorized_user?
            author = @ctx[:model].user_account
            is_valid = author == @current_user || @current_user.has_role?(:admin)
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Only an admin or the owner can delete this post', custom_predicate: :without_permissions )})

          end

          def delete_post
            begin
              @ctx[:model].discard!
              Success({ ctx: @ctx, type: :success })
            rescue => error
              Failure({ ctx: @ctx, type: :invalid })
            end
          end
        end
      end
    end
  end
end
