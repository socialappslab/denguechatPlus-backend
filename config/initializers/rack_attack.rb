# config/initializers/rack_attack.rb

module Rack
  class Attack
    if Rails.env.production?
      redis_client = Redis.new(url: ENV.fetch('REDIS_URL', nil))
      Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(redis: redis_client)
    else
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    end
    throttle('req/ip', limit: 2000, period: 5.minutes) do |req|
      req.ip
    end

    self.throttled_responder = ->(_env) do
      [
        429,
        { 'Content-Type' => 'application/json' },
        [{ error: 'You have exceeded the request limit. Please try again later.' }.to_json]
      ]
    end
  end
end
