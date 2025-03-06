# frozen_string_literal: true

class VersionSupports
  MOBILE_APP_CLIENT_DEVICE = 'mobile'
  ENVS_TO_SKIP_AUTH = %w[test].freeze
  PATHS_TO_SKIP_AUTH = %w[health sidekiq web].freeze
  DEPRECATED_RESPONSE = -> {
    [
      426,
      { 'Content-Type' => 'application/json' },
      [
        { errors: [
          {
            detail: I18n.t('errors.app_version_deprecated'),
            source: {
              pointer: '/data/attributes/base'
            }
          },
          {
            detail: I18n.t('errors.app_version_deprecated'),
            source: {
              pointer: '/data/attributes/app-version'
            }
          }
        ] }.to_json
      ]
    ]
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    @app_version = env['HTTP_X_APP_VERSION']
    @client_device = env['HTTP_X_CLIENT_DEVICE']

    return app.call(env) if ENV['ENABLE_MOBILE_VERSION_CHECK'] && ENV['ENABLE_MOBILE_VERSION_CHECK'] != '1'
    return app.call(env) if skip_env? || !deprecated?(env)

    Rails.logger.debug { "Unsupported mobile app version: #{app_version}" }
    DEPRECATED_RESPONSE.call
  end

  private

  attr_reader :app, :app_version, :client_device

  def deprecated?(env)
    return false if skip_path?(env)
    return true unless client_device

    mobile_app? && deprecated_version?
  end

  def deprecated_version?
    return true unless Gem::Version.correct?(app_version)

    Gem::Version.new(app_version) < Gem::Version.new(ENV.fetch('MINIMAL_SUPPORTED_APP_VERSION', '1.0.0'))
  end

  def mobile_app?
    client_device == MOBILE_APP_CLIENT_DEVICE
  end

  def skip_env?
    ENVS_TO_SKIP_AUTH.include?(Rails.env)
  end

  def skip_path?(env)
    path = env['ORIGINAL_FULLPATH'].to_s
    PATHS_TO_SKIP_AUTH.each do |path_to_skip|
      return true if path.match?(path_to_skip)
    end

    false
  end
end
