# frozen_string_literal: true

module HttpAuthConcern
  extend ActiveSupport::Concern

  included do
    include ActionController::HttpAuthentication::Basic::ControllerMethods

    # before_action :http_authenticate
  end

  def http_authenticate
    #    return true if skip_basic_auth?

    Rails.application.credentials.basic_auth
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == ENV.fetch('SIDEKIQ_USERNAME', '') && password == ENV.fetch('SIDEKIQ_PASSWORD', '')
    end
  end

  private

  def skip_basic_auth?
    Constants::BasicAuth::ENVS_TO_SKIP_AUTH.include?(Rails.env)
  end
end
