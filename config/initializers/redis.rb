# frozen_string_literal: true

size = ENV.fetch('REDIS_POOL_SIZE', 25)

RedisConnectionPool = ConnectionPool.new(size:) do
  Rails.application.config.redis_instance
end
