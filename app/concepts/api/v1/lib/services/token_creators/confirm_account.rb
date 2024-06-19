# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Services
        module TokenCreators
          class ConfirmAccount
            include Inject[
              redis_cache_repo: 'repositories.redis_cache',
              jwt_adapter: 'adapters.jwt'
            ]

            def self.call(user_account)
              new(user_account).call
            end

            def initialize(user_account, **_deps)
              @user_account = user_account
              @jwt_adapter = _deps[:jwt_adapter]
              @redis_cache_repo = _deps[:redis_cache_repo]
            end

            def call
              token = confirmation_token
              @redis_cache_repo.persist(
                key: "confirm-user-account-#{@user_account.id}",
                payload: { token: },
                exp_at: 5.years.from_now.to_i
              )
              token
            end

            private

            attr_reader :user_account

            def confirmation_token
              @jwt_adapter.encode(
                sub: user_account.id
              )
            end
          end
        end
      end
    end
  end
end
