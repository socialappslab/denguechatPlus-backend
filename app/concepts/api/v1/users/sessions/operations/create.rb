# frozen_string_literal: true

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
            step :authenticate
            step :check_account_status
            tee :access_expiration
            step :create_tokens

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
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
              model = UserAccount.find_by(searched_field => searched_value)

              unless model
                add_errors(@ctx['contract.default'].errors,'', I18n.t('errors.session.wrong_credentials'), '',[], :credentials_wrong?)
                return Failure({ ctx: @ctx, type: :unauthenticated })
              end
              @ctx[:model] = model
              Success({ ctx: @ctx, type: :success })
            end

            def authenticate
              unless @ctx[:model].authenticate(@params[:password])
                add_errors(@ctx['contract.default'].errors,'', I18n.t('errors.session.wrong_credentials'), '',[], :credentials_wrong?)
                return Failure({ ctx: @ctx, type: :unauthenticated })
              end
              Success({ ctx: @ctx, type: :success })
            end

            def check_account_status
              is_active = Api::V1::Users::Lib::CheckAccountActive.call(@ctx, model: @ctx[:model])

              if is_active
                Success({ ctx: @ctx, type: :success })
              else
                add_errors(@ctx['contract.default'].errors,nil, I18n.t('errors.unauthorized'))
                Failure({ ctx: @ctx, type: :unauthenticated })
              end
            end

            def access_expiration
              @ctx[:access_exp] = Constants::User::ACCESS_TOKEN_EXPIRATION
              @ctx[:refresh_exp] = Constants::User::REFRESH_TOKEN_EXPIRATION
            end

            def create_tokens
              result = Api::V1::Users::Lib::CreateTokens.call(@ctx, account: @ctx[:model])

              if result
                @ctx[:meta] = { jwt: Api::V1::Lib::Serializers::NamingConvention.new(result, :to_camel_case) }
                Success({ ctx: @ctx, type: :created })
              else
                add_errors(@ctx['contract.default'].errors,nil, I18n.t('errors.session.deactivated'))
                Failure({ ctx: @ctx, type: :unauthenticated })
              end
            end
          end
        end
      end
    end
  end
end
