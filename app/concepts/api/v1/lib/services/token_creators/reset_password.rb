# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Services
        module TokenCreators
          class ResetPassword
            include Inject[jwt_adapter: 'adapters.jwt']

            DEFAULT_TOKEN_EXPIRATION = 24.hours

            def self.call(...)
              new.call(...)
            end

            def call(model)
              account_type_key = "#{Api::V1::Lib::Services::AuthAccountType.call(model)}_account_id"
              jwt_adapter.encode(
                aud: 'reset_password',
                account_type_key => model.id,
                exp: DEFAULT_TOKEN_EXPIRATION.from_now.to_i
              )
            end
          end
        end
      end
    end
  end
end
