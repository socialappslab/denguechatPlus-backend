# frozen_string_literal: true

module Adapter
  class Redis
    def set(key, value)
      redis { |connection| connection.set(key, value) }
    end

    def get(key)
      redis { |connection| connection.get(key) }
    end

    def del(*key)
      redis { |connection| connection.del(key) }
    end

    def expire(key, exp)
      redis { |connection| connection.expire(key, exp) }
    end

    def expireat(key, exp)
      redis { |connection| connection.expireat(key, exp) }
    end

    def exists(value)
      redis { |connection| connection.exists(value) }
    end

    def hgetall(key)
      redis { |connection| connection.hgetall(key) }
    end

    def mapped_hmset(key, hash)
      redis { |connection| connection.mapped_hmset(key, hash) }
    end

    def hget(key, field)
      redis { |connection| connection.hget(key, field) }
    end

    def type(key)
      redis { |connection| connection.type(key) }
    end

    def ttl(key)
      redis { |connection| connection.ttl(key) }
    end

    def pttl(key)
      redis { |connection| connection.pttl(key) }
    end

    def keys(pattern = '*')
      redis { |connection| connection.keys(pattern) }
    end

    def rpush(key, value)
      redis { |connection| connection.rpush(key, value) }
    end

    def lrem(key, count, value)
      redis { |connection| connection.lrem(key, count, value) }
    end

    def lrange(key, start, stop)
      redis { |connection| connection.lrange(key, start, stop) }
    end

    def incr(key)
      redis { |connection| connection.incr(key) }
    end

    def flushall
      redis(&:flushall)
    end

    private

    def redis(&)
      RedisConnectionPool.with(&)
    end
  end
end
