# Some experimental providers

module LogProvider
  include CollectionHandler
  require 'redis'

  def self.init_store
    puts 'seeding...'
    redis = Redis.new
    @@keys = []
    TestEvent.all(:limit => 100000).each do |test_event|
      redis.hset 'log_events', test_event.id, test_event.to_json
      @@keys << test_event.id
    end
    puts 'seeded!'
  end

  def iterator
    keys.each do |k|
      yield JSON.parse redis.hget('log_events', k)
    end
  end

  def get(key)
    redis.hget 'log_events', key
  end

  private

  def redis
    @redis ||= Redis.new
  end

  def keys
    @@keys
  end
end

module MemcLogProvider
  include CollectionHandler
  require 'memcached'

  def self.init_store
    puts 'seeding..'
    m = Memcached.new
    @@keys = []
    TestEvent.all(:limit => 100000).each do |test_event|
      key = "log_events:#{test_event.id}"
      m.set key, test_event.to_json
      @@keys << key
    end
    puts 'seeded!'
  end

  def iterator
    @@keys.each do |key|
      yield JSON.parse m.get key
    end
  end

  private

  def m
    @memc ||= Memcached.new
  end
end

module RedisListLogProvider
  include CollectionHandler
  require 'redis'
  require 'json'

  def self.init_store
    puts 'seeding'
    r = Redis.new
    r.del 'log_events_list'
    10.times do |i|
      TestEvent.all(:limit => 1000, :offset => i * 1000).each do |te|
        r.rpush 'log_events_list', te.to_json
      end
    end
    puts 'seeded!'
  end

  def iterator
    redis.lrange('log_events_list', 0, -1).each do |data|
      yield JSON.parse(data)
    end
  end

  private

  def redis; @redis ||= Redis.new; end
end
