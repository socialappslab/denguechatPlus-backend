# frozen_string_literal: true

module Repository
  class RedisCache
    include Inject['adapters.redis']

    GETTERS = { 'hash' => :hgetall, 'string' => :get, 'integer' => :get }.freeze
    SETTERS = { Hash => :mapped_hmset, String => :set, Integer => :set }.freeze

    def persist(key:, payload:, exp: Constants::Tokens::DEFAULT_EXPIRATION_TIME, exp_at: nil)
      payload_class = payload.class
      return false unless SETTERS.key?(payload_class)

      redis.public_send(SETTERS[payload_class], key, payload)

      if exp_at
        redis.expireat(key, exp_at)
      elsif exp
        redis.expire(key, exp)
      end
    end

    def find(key:)
      return false unless redis.exists(key)

      value_type = redis.type(key)
      return false unless GETTERS.key?(value_type)

      value = redis.send(GETTERS[value_type], key)
      return false if value.empty?

      return value.deep_symbolize_keys if value.is_a?(Hash)

      value
    end

    def delete(key:)
      redis.del(key)
    end

    def expire(key:, ttl:)
      redis.expire(key, ttl)
    end

    def expireat(key:, exp_at:)
      redis.expireat(key, exp_at)
    end

    def ttl(key:)
      redis.ttl(key)
    end

    def incr(key:)
      redis.incr(key)
    end
  end
end
