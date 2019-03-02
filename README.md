# CronZoneConverter

## Translate local Cron lines into UTC time 

The objective of this gem is to translate a single cron line in a time zone into 
a single/multiple cron line/s in UTC time. 

## Usage

### Cron Line

The first (required) parameter to the `convert` method is the cron line:

```ruby
CronZoneConverter.convert '0 16 * * 1-5 MST'
# => ["0 23 * * 1,2,3,4,5 MST"]
```

We use [Fugit::Cron](https://github.com/floraison/fugit) to parse the cron line. 
`Fugit` does allow parsing the time zone from the cron line like so:

```ruby
CronZoneConverter.convert '0 16 * * 1-5 MST'
# => ["0 23 * * 1,2,3,4,5 MST"]
```

But if you don't pass or setup a valid time zone you will get an error:

```ruby
CronZoneConverter.convert '0 16,20 * * 1-5'
CronZoneConverter
```

### Time Zones

The second parameter is the cron line zone. 
This gem uses [ActiveSupport](https://github.com/rails/rails/tree/master/activesupport) 
to identify available time zones. So you can setup the cron line time zone by:

* Passing a `zone` parameter: a `String` (zone name) or and `ActiveSupport::TimeZone`: 

```ruby
CronZoneConverter.convert '0 16 * * 1-5', 'MST'
# => ["0 23 * * 1,2,3,4,5 MST"]
CronZoneConverter.convert '0 16 * * 1-5', Time.find_zone('MST')
# => ["0 23 * * 1,2,3,4,5 MST"]
```

* A timezone defined in the cron line like we saw before:

```ruby
CronZoneConverter.convert '0 16,20 * * 1-5 MST'
```

* Or defining a global time zone:

```ruby
Time.zone =  'MST'
CronZoneConverter.convert '0 16 * * 1-5'
```

## Result

We always return an array with one or more cron lines (`String`).

### Why multiple lines?

Given that you could have multiple hours defined in a cron line when you convert that into some other time zone 
you could end up with some of the hours falling in one day and some other hours falling in another day. 

#### Single line

```ruby
CronZoneConverter.convert '0 16,20 * * 1-5 MST'
# => ['0 23 * * 1,2,3,4,5', '0 3 * * 2,3,4,5,6']
```

#### Multiple lines

```ruby
CronZoneConverter.convert '0 20,21 * * 1-5 MST'
# => ['0 3,4 * * 2,3,4,5,6']
``` 

## Origin Story
 
The need for this functionality came about by our continued use of 
[Sidekiq Enterprise Periodic Jobs](https://github.com/mperham/sidekiq/wiki/Ent-Periodic-Jobs#time-zones) 
and issues we ran with running jobs at our local time instead of the servers UTC time. 

This gem does consider DST (Daylight Saving Time) but please remember that you will need to restart your servers
for the time change to kick in for your Sidekiq workers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cron_zone_converter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cron_zone_converter

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acima-credit/cron_zone_converter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CronZoneConverter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/acima-credit/cron_zone_converter/blob/master/CODE_OF_CONDUCT.md).
