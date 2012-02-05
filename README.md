# favReduce

Just a naive, experimental and highly opinionated map/Reduce library. The objetive is to provide a very simple and clean way to describe complex data aggregation operation throught the map/reduce abstraction.

## Collections

The data scenario in which the aggregation tasks has to run is usually complex and with a lot of different sources/destinations. I tried to abstract all this heterogeneity by defining a extremely simple common interface in `CollectionHandler`. Each data source or destination has to be represented as a module implementing the interface operations, wich are basically a `get`/`set` mechanism and a `iterator` method responsible to fetch data one row/document/value/... at a time.

The `iterator` method will be used to read values from a data source and feed them to the `map` stage. The `get` and `set` operators are only for auxiliary usage inside the aggregation process. For example, to store the result value in the `finalize` phase.

This `CollectionHandlers` doesn't need to be only databases. One could implement, for example, a collection abstraction wich receives an url in the `set` method and uses it to grab an screenshot or gather some data about the speficied site.

## Map/Reduce

The whole point of the library is to provide a dead simple interface to describe map/reduce operations. You will see it clearly in a simple example:

Imagine that we have a log of visited urls inside our web site, and we are storing them as hashes with the form `{url: <string>}`. We have written a `CollectionHandler` called `UrlLogProvider` that feed us with the data in the right way and we want to just count the total visits of each url.

```ruby
class CountUrls
  include MapReduce
  include UrlLogProvider

  map do |log_event|
    emit(log_event['url'], 1)
  end

  reduce do |url, values|
    collect(url, values.reduce(&:+))
  end

  finalize do |url, total_visits|
    puts "#{url}: #{total_visits}"
  end
end
```

Thats all! To start the task, we just have to instantiate the class:

```ruby
CountUrls.new

```

## Included source files

Given the experimental nature of the library, I have left some examples and some alternative implementations of the library in the repo as a loosy replacement for proper documentation. You can see some `CollectionHandlers` implemented in `providers.rb`, some examples in `main.rb` and a simple log model that I have been using just for messing around in `log_models.rb` and `populate.rb`.
