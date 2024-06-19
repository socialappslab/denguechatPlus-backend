# frozen_string_literal: true

class Container
  extend Dry::Container::Mixin

  namespace 'adapters' do
    register('jwt') { Adapter::JWT }
    register('redis') { Adapter::Redis.new }
  end

  namespace 'repositories' do
    register('redis_cache') { Repository::RedisCache.new }
  end
end

Inject = Dry::AutoInject(Container)
