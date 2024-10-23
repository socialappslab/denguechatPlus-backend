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
              @ctx[:errors] = nil
              @ctx[:errors] = nil
            end

            def delete_user
              begin
                @current_user.update_columns(phone: "deleted_#{@ctx[:model].id}", username: "deleted_#{@ctx[:model].id}")
                user_profile = @current_user.user_profile
                user_profile.update_columns(first_name: "user_deleted_#{@ctx[:model].id}}",
                                            last_name: "user_deleted_#{@ctx[:model].id}",
                                            email: "deleted_#{@ctx[:model].id}@denguechatplus.com")
                return  Success({ ctx: @ctx, type: :destroyed }) if @ctx[:model].discarded?
                @ctx[:model].discard!
                flush_session_by_token.call(@found_token, @current_user)
                Success({ ctx: @ctx, type: :destroyed, model: @ctx[:model], success: true })
              rescue => error
                Success({ ctx: @ctx, type: :destroyed, model: @ctx[:model], success: true })
              end
            end

          end
        end
      end
    end
  end
end
