# frozen_string_literal: true

JWTSessions.token_store = Rails.application.config.jwt_token_store
JWTSessions.algorithm = 'HS256'
JWTSessions.encryption_key = ENV.fetch('JWT_SECRET_KEY', nil)
JWTSessions.access_header  = 'X-Authorization'
