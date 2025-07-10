# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ValidateCode < ApplicationOperation
            include Dry::Transaction

            ValidateCodeStruct = Struct.new(:url)

            tee :params
            step :validate_schema
            step :retrieve_user
            step :retrieve_all_codes
            step :validate_code_owner
            tee :update_code_data
            tee :create_token
            step :generate_url

            ROOT_URL = if Rails.env.production?
                         'https://denguechatplus.org/new_password'
                       else
                         'https://develop.denguechatplus.org/new_password'
                       end

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ValidateCode.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @user_account = UserAccount.where('LOWER(username) = ? AND phone = ?',
                                                @params[:username].downcase.gsub(/\s+/, ''), @params[:phone])&.first
              return Success({ ctx: @user_account, type: :success }) if @user_account

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found?) })
            end

            def retrieve_all_codes
              @codes = UserCodeRecovery.where(user_account_id: @user_account.id,
                                              used_at: nil,
                                              expired_at: Time.current..Float::INFINITY)
              return Success({ ctx: @user_account, type: :success }) if @codes&.any?

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found?) })
            end

            def validate_code_owner
              @code = @codes.find { |code| code.code == @params[:code] }
              return Success({ ctx: @user_account, type: :success }) if @code

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found?) })
            end

            def update_code_data
              @code.touch(:used_at)
            end

            def create_token
              @user_token = UserToken.create!(
                data_type: 'recovery',
                event: 'password_recovery',
                token: SecureRandom.hex(16),
                user_account_id: @user_account.id,
                user_code_recovery_id: @code.id
              )
            end

            def generate_url
              @ctx[:data] = ValidateCodeStruct.new("#{ROOT_URL}/#{@user_token.token}")
              Success({ ctx: @ctx, type: :success })
            end
          end
        end
      end
    end
  end
end
