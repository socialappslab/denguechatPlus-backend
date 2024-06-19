# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Confirm < ApplicationOperation
            include Dry::Transaction
            include Inject[cache_repo: 'repositories.redis_cache',
                           jwt_adapter: 'adapters.jwt']

            tee :params
            step :validate_schema
            step :decode_token
            step :find_token_in_redis_store
            step :tokens_matches?
            step :find_user_account
            tee :confirm_account
            tee :remove_token
            step :authenticate

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Token.new(@params)
              is_valid = @ctx['contract.default'].validate(@params)
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def inject_container
              include Inject[
                        cache_repo: 'repositories.redis_cache',
                        jwt_adapter: 'adapters.jwt'
                      ]
            end

            def decode_token
              begin
                @ctx[:user_account_id] = jwt_adapter.decode(@ctx['contract.default'].model[:token]).first['sub']
                @ctx[:redis_token_key] = "confirm-user-account-#{@ctx[:user_account_id]}"
              rescue JWT::ExpiredSignature, JWT::DecodeError => error
                error_type = error.instance_of?(JWT::ExpiredSignature) ? 'errors.token.expired' : 'errors.token.invalid'
                @ctx['contract.default'].errors.add(:base, I18n.t(error_type))
                Failure({ ctx: @ctx, type: :invalid })
              end
            end

            def find_token_in_redis_store
              @ctx[:redis_token_key] = cache_repo.find(key: @ctx[:redis_token_key])
              return Success(@ctx) if @ctx[:redis_token_key]

              @ctx['contract.default'].errors.add(:base, I18n.t('errors.token.invalid'))

              Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:redis_token_key]
            end

            def tokens_matches?
              is_equal = @ctx[:redis_token_key][:token].eql?(@params[:token])
              return Success(@ctx) if is_equal

              @ctx['contract.default'].errors.add(:base, I18n.t('errors.token.invalid'))

              Failure({ ctx: @ctx, type: :invalid }) unless is_equal
            end

            def find_user_account
              @ctx[:user_account] = UserAccount.find_by(id: @ctx[:user_account_id])
              return Success(@ctx) if @ctx[:user_account]

              @ctx['contract.default'].errors.add(:base, I18n.t('errors.token.invalid'))

              Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:user_account]
            end

            def confirm_account
              @ctx[:user_account].touch(:confirmed_at)
            end

            def remove_token
              cache_repo.delete(key: "confirm-user-account-#{@ctx[:user_account_id]}")
            end

            def authenticate
              result = Api::V1::Users::Lib::CreateTokens.call(@ctx, account: @ctx[:user_account])

              if result
                @ctx[:meta] = { jwt: result }
                Success({ ctx: @ctx, type: :created })
              else
                @ctx['contract.default'].errors.add(:base, I18n.t('errors.session.deactivated'))
                Failure({ ctx: @ctx, type: :unauthenticated })
              end
            end
          end
        end
      end
    end
  end
end
