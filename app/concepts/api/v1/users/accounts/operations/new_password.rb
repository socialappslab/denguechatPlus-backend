# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class NewPassword < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :validate_token
            step :retrieve_user
            step :validate_password
            step :update_password

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::NewPassword.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def validate_token
              @user_token = UserToken.find_by(token: @params[:token],
                                              used_at: nil)
              return Success({ ctx: @user_account, type: :success }) if @user_token

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'Invalid token', custom_predicate: :format?) })
            end

            def retrieve_user
              @user_account = UserAccount.find_by(id: @user_token.user_account_id)
              return Success({ ctx: @user_account, type: :success }) if @user_account

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'User not found', custom_predicate: :not_found?) })
            end

            def validate_password
              if @params[:password].downcase == @params[:password_confirmation].downcase
                return Success({ ctx: @user_account,
                                 type: :success })
              end

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'Passwords do not match', custom_predicate: :format?) })
            end

            def update_password
              @user_account.password = @params[:password].downcase
              if @user_account.save
                @ctx[:data] = @user_account
                @user_token.touch(:used_at)
                return Success({ ctx: @ctx, type: :success })
              end
              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base,
                                                        msg: 'Error updating passwords',
                                                        custom_predicate: :unexpected_key) })
            end
          end
        end
      end
    end
  end
end
