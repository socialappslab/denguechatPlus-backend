Sentry.init do |config|
  config.dsn = ENV.fetch("SENTRY", '')

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 1.0
  config.profiles_sample_rate = 1.0
  config.background_worker_threads = 0 if Rails.env.test?
  config.background_worker_threads = 1 if Rails.env.development?

  config.before_send = lambda do |event, hint|
    if event.user_account.nil? && defined?(Current) && Current.user_account
      event.user = { id: Current.user_account.id, username: Current.user_account.username }
    end
    event
  end
end
