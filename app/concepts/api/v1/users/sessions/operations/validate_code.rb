# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
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
            tee :access_expiration
            step :create_token


            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end
            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Sessions::Contracts::ValidateCode.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @user_account = UserAccount.find_by("phone = ?", @params[:phone])
              return Success({ ctx: @user_account, type: :success }) if @user_account

              Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found? )})

            end

            def retrieve_all_codes
              @codes = UserCodeRecovery.where(user_account_id: @user_account.id,
                                              used_at: nil,
                                              expired_at: Time.current..Float::INFINITY)
              return Success({ ctx: @user_account, type: :success }) if @codes&.any?

              Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found? )})

            end

            def validate_code_owner
              @code = @codes.find { |code| code.code == @params[:code] }
              return Success({ ctx: @user_account, type: :success }) if @code

              Api::V1::Users::Lib::LoginAttempt.call(@user_account).increase_attempts_count!
              Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Invalid code', custom_predicate: :not_found? )})
            end

            def update_code_data
              @code.touch(:used_at)
            end

            def access_expiration
              @ctx[:access_exp] = is_mobile? ? Constants::User::ACCESS_TOKEN_EXPIRATION_MOBILE : Constants::User::ACCESS_TOKEN_EXPIRATION_WEB
              @ctx[:refresh_exp] = is_mobile? ? Constants::User::REFRESH_TOKEN_EXPIRATION_MOBILE : Constants::User::REFRESH_TOKEN_EXPIRATION_WEB
            end

            def create_token
              result = Api::V1::Users::Lib::CreateTokens.call(@ctx, account: @user_account,
                                                              refresh_exp: @ctx[:refresh_exp],
                                                              access_exp: @ctx[:access_exp])

              if result
                @ctx[:meta] = { jwt: Api::V1::Lib::Serializers::NamingConvention.new(result, :to_camel_case) }
                Success({ ctx: @ctx, type: :created })
              else
                Failure({ ctx: @ctx, type: :unauthenticated, errors: ErrorFormater.new_error(field: :base, msg: I18n.t('errors.session.deactivated'), custom_predicate: :credentials_wrong? ) })
              end
            end

            private

            def is_mobile?
              @browser ||= Browser.new(@agent)
              @browser.device.mobile? || @source == 'mobile'
            end



          end
        end
      end
    end
  end
end
