# PumaNewrelicStats

A Ruby gem that collects Puma server statistics and reports them to New Relic. It works with both single and cluster mode Puma servers, providing metrics about backlog, running threads, pool capacity, and request counts.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma_newrelic_stats'
```

Add this line to `config/puma.rb`:

```ruby
activate_control_app
```

And then execute:

```bash
bundle install
```

## Usage

Configure the gem in an initializer:

```ruby
# filepath: config/initializers/puma_newrelic_stats.rb
PumaNewrelicStats.configure do |config|
  config.interval = 15      # Stats collection interval in seconds (default: 15)
  config.control_port = 9293  # Puma control port (default: 9293)
  config.control_url = "http://127.0.0.1:9293/puma/stats"  # Custom stats URL if needed
end

PumaNewrelicStats.start
```

### Metrics Collected

The following metrics are reported to New Relic:

- `Custom/Puma/Total/Backlog` - Total number of backlog requests
- `Custom/Puma/Total/RunningThreads` - Total number of running threads
- `Custom/Puma/Total/PoolCapacity` - Total thread pool capacity
- `Custom/Puma/Total/MaxThreads` - Total maximum threads
- `Custom/Puma/Total/RequestsCount` - Total number of requests processed

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codeur/puma-newrelic-stats. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/codeur/puma-newrelic-stats/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PumaNewrelicStats project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codeur/puma-newrelic-stats/blob/master/CODE_OF_CONDUCT.md).
