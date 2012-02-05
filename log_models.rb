require 'data_mapper'

# DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/favreduce.sqlite")
DataMapper.setup(:default, "postgres://elias:elias@localhost/favreduce")

class TestEvent
  include DataMapper::Resource

  property :id,   Serial
  property :url,  String
  property :from, Integer
  property :to,   Integer
  property :date, DateTime
end

DataMapper.finalize
