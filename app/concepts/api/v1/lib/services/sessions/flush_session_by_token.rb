# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Services
        module Sessions
          class FlushSessionByToken
            def initialize(refresh_token, account)
              @refresh_token = refresh_token
              @account = account
            end

            def self.call(...)
              new(...).call
            end

            def call
              session = JWTSessions::Session.new
              session.flush_by_token(refresh_token)
            rescue JWTSessions::Errors::Unauthorized # rubocop:disable Lint/SuppressedException
            end

            attr_reader :refresh_token, :account

            private

            def namespace
              "user-account-#{account.id}"
            end

            def payload
              { account_id: account.id }
            end

            def refresh_payload
              { account_id: account.id }
            end
          end
        end
      end
    end
  end
end
