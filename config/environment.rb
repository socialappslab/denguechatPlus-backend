# frozen_string_literal: true

# config/environment.rb
require File.expand_path('application', __dir__)

notify = ->(e) do
  begin
    Sentry.configure_scope do |scope|
      scope.set_tags(async: false)
      Sentry.capture_exception(e)
    end
  rescue StandardError
    Rails.logger.error 'Synchronous Sentry notification failed. Sending async to preserve info'
    Sentry.capture_exception(e)
  end
end

begin
  Rails.application.initialize!
rescue Exception => error
  notify.call(error)
  raise
end
