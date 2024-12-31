# frozen_string_literal: true
require "browser"

module Api
  module V1
    module Users
      module Sessions
        module Operations
          class Create < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :model
            step :check_account_status
            step :authenticate
            tee :access_expiration
            step :create_tokens

            def params(input)
              @ctx = {}
              @ctx['errors'] = []
              @params = input.fetch(:params)
              @agent = input.fetch(:agent)
              @source = input.fetch(:source)
              is_mobile?
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Sessions::Contracts::Create.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid })
            end

            def model
              searched_field = @ctx['contract.default'][:type]
              searched_value = @ctx['contract.default'][searched_field]
              model = UserAccount.find_by(searched_field => searched_value.downcase)

              unless model
                return Failure({ ctx: @ctx, type: :unauthenticated,
                                 errors: ErrorFormater.new_error(field: :base, msg: I18n.t('errors.session.wrong_credentials'), custom_predicate: :credentials_wrong?) })
              end
              @ctx[:model] = model
              Success({ ctx: @ctx, type: :success })
            end

            def check_account_status
              if @ctx[:model].active?
                Success({ ctx: @ctx, type: :success })
              elsif @ctx[:model].inactive?
                Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'your account is inactive', custom_predicate: :user_account_without_confirmation? )})
              elsif @ctx[:model].pending?
                Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'your account is pending to active', custom_predicate: :user_account_without_confirmation? )})
              else
                Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'your account is locked', custom_predicate: :user_account_locked? )})
              end
            end

            def authenticate
              unless @ctx[:model].authenticate(@params[:password])
                Api::V1::Users::Lib::LoginAttempt.call(@ctx[:model]).increase_attempts_count!

                return Failure({ ctx: @ctx, type: :unauthenticated, errors: ErrorFormater.new_error(field: :base, msg: I18n.t('errors.session.wrong_credentials'), custom_predicate: :credentials_wrong?) })
              end

              Success({ ctx: @ctx, type: :success })
            end

            def access_expiration
              @ctx[:access_exp] = is_mobile? ? Constants::User::ACCESS_TOKEN_EXPIRATION_MOBILE : Constants::User::ACCESS_TOKEN_EXPIRATION_WEB
              @ctx[:refresh_exp] = is_mobile? ? Constants::User::REFRESH_TOKEN_EXPIRATION_MOBILE : Constants::User::REFRESH_TOKEN_EXPIRATION_WEB
            end

            def create_tokens
              result = Api::V1::Users::Lib::CreateTokens.call(@ctx, account: @ctx[:model],
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
