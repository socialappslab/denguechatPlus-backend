# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class CreateTokens
          def self.call(ctx,
                        account:,
                        refresh_exp:,
                        access_exp:,
                        **)
            payload = { account_id: account.id, app: 'dengue_chat_plus', verify_aud: true }
            session = JWTSessions::Session.new(
              payload:,
              refresh_payload: payload,
              access_exp:,
              refresh_exp:
            )
            ctx[:tokens] = session.login
          end
        end
      end
    end
  end
end
