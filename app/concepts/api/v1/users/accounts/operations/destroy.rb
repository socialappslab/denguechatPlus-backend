# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Destroy < ApplicationOperation
            include Dry::Transaction

            tee :params
            tee :retrieve_user
            step :delete_user

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @current_user = input[:current_user]
              @found_token = input[:found_token]
            end

            def retrieve_user
              @ctx[:model] = @current_user
            end

            def delete_user
              Api::V1::Users::Lib::DiscardAccount.call(user_account: @current_user)
              flush_session_by_token.call(@found_token, @current_user) if @found_token

              Success({ ctx: @ctx, type: :destroyed, model: @ctx[:model] })
            rescue StandardError
              Success({ ctx: @ctx, type: :destroyed, model: @ctx[:model] })
            end
          end
        end
      end
    end
  end
end
