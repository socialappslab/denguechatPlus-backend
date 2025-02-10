Sentry.init do |config|
  config.dsn = ENV.fetch("SENTRY", '')

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 1.0
  config.profiles_sample_rate = 1.0
  config.background_worker_threads = 0 if Rails.env.test?
  config.background_worker_threads = 1 if Rails.env.development?


end
