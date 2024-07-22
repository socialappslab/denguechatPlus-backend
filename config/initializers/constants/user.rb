# frozen_string_literal: true

module Constants
  module User
    ACTIVITY_TIMEOUT = %w[staging development sandbox].include?(Rails.env) ? 2.hours : 30.minutes
    REFRESH_TOKEN_EXPIRATION = 9.hours.to_i
    ACCESS_TOKEN_EXPIRATION = 10.minutes.to_i
    PASSWORD_MIN_LENGTH = 8
    STATUS = %w[active inactive pending locked].freeze
    FILTERS = %w[user_account.id user_account.username user_account.phone user_account.created_at user_profiles.created_at user_profiles.first_name user_profiles.last_name
                 user_account.phone organizations.name cities.name neighborhoods.name teams.name].freeze
  end
end
