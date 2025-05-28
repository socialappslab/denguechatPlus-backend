# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class RefreshToken

          def self.call(payload:, found_token:)
            session = JWTSessions::Session.new(payload:)
            session.refresh(found_token)
          end

        end
      end
    end
  end
end
