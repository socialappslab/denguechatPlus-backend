# frozen_string_literal: true

module Constants
  module User
    ACTIVITY_TIMEOUT = %w[staging development sandbox].include?(Rails.env) ? 2.hours : 30.minutes
    REFRESH_TOKEN_EXPIRATION = 9.hours.to_i
    ACCESS_TOKEN_EXPIRATION = 10.minutes.to_i
    PASSWORD_MIN_LENGTH = 8
  end
end
