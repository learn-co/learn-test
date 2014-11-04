# Ironboard

Runs RSpec and Jasmine test suites and uploads the results to Flatiron
School's Ironboard.

## Installation

Add the Flatiron School gem server to your list of sources:

```
$ gem sources -a http://flatiron:33west26@flatironschool.com
```

And then install with:

```
$ gem install ironboard
```

Alternatively, add this line to your application's Gemfile:

```ruby
gem 'ironboard', source: 'http://flatiron:33west26@flatironschool.com'
```

And then execute:

    $ bundle

## Usage

From within a directory with either an RSpec or Jasmine test suite, run:

```
$ ironboard
```

## Contributing

1. Fork it ( https://github.com/flatiron-labs/ironboard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

