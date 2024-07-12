# frozen_string_literal: true

JWTSessions.token_store = ENV.fetch('JWT_TOKEN_STORE', :redis).to_sym
JWTSessions.algorithm = 'HS256'
JWTSessions.encryption_key = ENV.fetch('JWT_SECRET_KEY', nil)
JWTSessions.access_header  = 'X-Authorization'
