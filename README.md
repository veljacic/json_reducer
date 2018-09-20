# JsonReducer

Reduces hash based on given schema. If you want to render just one part of the hash this gem will make that easy. Just create JSON schema for desired response and gem will do the rest.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_reducer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_reducer

## Usage

First create an initializer inside initializers folder. You can call it json_reducer but that is up to you.
Here you can define your base_path to schemas and register them.

```ruby
JsonReducer.base_path(Rails.root.join('lib', 'schemas'))  # don't forget to create schemas folder

JsonReducer.register(:example1, 'example1.json')
JsonReducer.register(:example2, { foo: {bar: {title: 'BAR'} } }, file: false)
JsonReducer.register(:example3, {"foo": {"bar": {"title": "BAR"}}}, file: false)
```

You can pass filename, json or hash. Just set file option to false for hash or json.
When you want to register schema using path pass schema filename. In our example schema source is in: '/lib/schemas/example1.json'

JSON schema example:

```json
{
  "type": "object",
  "properties": {
    "foo": {
      "type": "object",
      "properties": {
        "bar": {"type": "object"}
      }
    },
    "abc": {
      "type": "array",
      "properties": {
        "id": { "type" : "string" }
      }
    }
  }
}
```

In JSON schema you are just whitelisting the properties which you want to use. If you exclude field in properties it will be excluded in response
but if you completely omit properties in JSON schema all object fields for that property object will be parsed.
It is important to set type correctly, especially for arrays otherwise hash won't be parsed correctly.

## Example

```
payload = {
  foo: {
    bar: {
      title: 'BAR',
      body: 'Body of the BAR'
    },
    baz: 'BAZ'
  },
  abc: {
    def: 'DEF'
  },
  dbc: {
    fed: 'FED'
  }
}
```

```json
schema = {
  "type": "object",
  "properties": {
    "foo": {
      "type": "object",
      "properties": {
        "bar": {
          "type": "object",
          "properties": {
            "title": { "type": "string" }
            /* omitting body to exclude it from response */
          }
        }
      }
    },
    "dbc": {
      "type": "object"  
      /* omitting properties to parse all */
    }
  }
}
```

Registering the schema and applying it on given payload.

```
JsonReducer.register(:test, schema, file: false)
JsonReducer.new(:test).apply(payload)
```

Will result with

```
payload = {
  'foo' => {
    'bar' => {
      'title' => 'BAR'
    }
  },
  'dbc' => {
    'fed' => 'FED'
  }
}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/json_reducer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JsonReducer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/json_reducer/blob/master/CODE_OF_CONDUCT.md).
