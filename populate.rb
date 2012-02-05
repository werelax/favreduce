require_relative 'log_models'

DataMapper.auto_migrate!

def rand_string(len)
  rand(36**len).to_s(36)
end

def rand_date
  from = Time.now.to_i - (3600*24*30*2) # two months ago
  to = Time.now.to_i
  time = rand * (to - from) + from
  Time.at(time)
end

urls = Array.new(1000).map { "http://#{rand_string(10)}.com"}

# Logging 10k random events

1000000.times do |i|
  TestEvent.create url: urls[rand(1000)], from: rand(100), to: rand(100), date: rand_date
  print '.' if (i % 1000) == 0
end

