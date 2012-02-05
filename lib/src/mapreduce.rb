# Naive map/reduce library

module RedisStorage

  def initialize
    @mapped_collection = 'mr_mapped'
    @results_collection = 'mr_results'
    @keys = []
  end

  def add_mapped(k, v)
    @keys << k
    redis.lpush "#{@mapped_collection}:#{k}", v.to_json
  end

  def add_results(k, v)
    # Beware! v HAS to be a HASH
    data = {k: k, v: v}.to_json
    redis.lpush @results_collection, data
  end

  def mapped_iterator
    @keys.each do |k|
      list_name = "#{@mapped_collection}:#{k}"
      list = redis.lrange(list_name, 0, -1)
      list = list.map {|i| i.length > 1 ? JSON.parse(i) : i.to_i }
      yield(k, list)
      redis.del list_name
    end
  end

  def results_iterator
    len = redis.llen @results_collection
    len.times do
      item = JSON.parse redis.lpop(@results_collection)
      key = item.delete(:k)
      value = item.delete(:v)
      yield key, value
    end
    redis.del @results_collection
  end

  private

  def redis
    @redis ||= Redis.new
  end
end

module MemoryStorage

  def initialize
    @map_collection = {}
    @results_collection = {}
    @keys = []
  end

  def add_mapped(k, v)
    @keys << k
    (@map_collection[k] ||= []) << v
  end

  def add_results(k, v)
    @results_collection[k] = v
  end

  def mapped_iterator
    @keys.each {|k| yield k, @map_collection[k] }
  end

  def results_iterator
    @keys.each {|k| yield k, @results_collection[k] }
  end

end

module MapReduce
  include MemoryStorage

  def self.included(base)
    base.extend(ClassMacros)
  end

  module ClassMacros
    def map(&block)
      define_method :mapper, block
    end

    def reduce(&block)
      define_method :reducer, block
    end

    def finalize(&block)
      define_method :finalize, block
    end
  end

  # Iterator is an abstract method
  def iterator
    raise "Implement or include an iterator"
  end


  def initialize
    super

    Benchmark.bm(10) do |bm|

      bm.report 'map' do
        iterator do |data|
          mapper(data)
        end
      end

      bm.report 'reduce' do
        mapped_iterator do |k, v_list|
          reducer(k, v_list)
        end
      end

      bm.report 'finalize' do
        results_iterator {|k, v| finalize(k, v) }
      end

    end
  end

  def emit(key, value)
    add_mapped key, value
  end

  def collect(key, value)
    add_results key, value
  end
end
