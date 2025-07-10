# frozen_string_literal: true

module Adapter
  class JWT
    SECRET_KEY = ENV.fetch('JWT_SECRET_KEY', nil)

    class << self
      def encode(payload)
        ::JWT.encode(payload, SECRET_KEY)
      end

      def decode(token, verify: true, **)
        ::JWT.decode(token, SECRET_KEY, verify, **)
      end
    end
  end
end
