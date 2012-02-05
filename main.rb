%w{log_models mapreduce collection providers}.each {|lib| require_relative lib }
require 'benchmark'

# Map task 1: count the times each url has been visited

class CountUrls
  include MapReduce
  include RedisListLogProvider

  map do |log_event|
    emit(log_event['url'], 1)
  end

  reduce do |url, values|
    collect(url, values.reduce(&:+))
  end

  finalize do |url, value|
    # puts "#{url}: #{value}"
  end

end

CountUrls.new


# Map task 2: count the times each user has been visited

class CountUserVisits
  include MapReduce
  include RedisListLogProvider

  map do |log_event|
    emit(log_event['to'], 1)
  end

  reduce do |user, values|
    collect(user, values.reduce(&:+))
  end

  finalize do |user, value|
    # puts "User #{user} has been visited #{value} times"
  end

end

CountUserVisits.new
