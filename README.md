# SimpleJson

A simple & fast solution for Rails JSON rendering.

## Get started

In Gemfile

```ruby
gem 'simple_json'
```

In controller

```ruby
class ApplicationController < ActionController::Base
  include SimpleJson::SimpleJsonRenderable

  ...
end
```

In view, create your simple_json template file in `app/views`.

```ruby
# {controller_name}/{action_name}.simple_json.rb
{
  key1: @value1,
  key2: helper(@value2),
  key3: partial!("partial_path", param1: param1, param2: param2)
}
```

And, partial as well.

```ruby
->(param1:, param2:) {
  {
    key1: param1,
    key2: param2,
  }
}

```

That's all!

Have fun!

## Special thanks

This project is built on work of [jb](https://github.com/amatsuda/jb).

## Template Syntax

SimpleJson templates should be written in Ruby lambda format. The template code is converted into a method and then invoked to produce data (Hashes or Arrays) for JSON.

```ruby
-> {
  {
    key: @value,
  }
}
```

When no parameters specified, `-> {` and `}` can be omitted.

```ruby
{
  key: @value,
}
```

Use `partial!` method to call another template in template. Note that path is always required. Also, there is no difference between partials and templates, so that you cannot omit `_` before template name.
(So, no omitting for template path is allowed.)

```ruby
# app/views/posts/show.simple_json.rb
{
  title: @post.title,
  comments: @post.comments.map { |comment| partial!('comments/_comment', comment: comment) }
}
```

```ruby
# app/views/comments/_comment.simple_json.rb
->(comment:) {
  {
    body: comment.body
  }
}
```

Cache helpers of simple_json is similar to jbuilder.

```ruby
cache! key, options do
  data_to_cache
end
```

Cache helpers uses `Rails.cache` to cache, so array keys, expirations are available. Make sure `perform_caching` is enabled.

```ruby
cache! [key1, key2], expires_in: 10.minutes do
  data_to_cache
end
```

`cache_if!` is also available

```ruby
cache_if! boolean, key1, options do
  data_to_cache
end
```

You can set key_prefix for caching like this

```ruby
SimpleJson.cache_key_prefix = "MY_PREFIX"
```

## Configurations

Load all templates on boot. (For production)
Templates loaded will not load again, so it is not recommended in development environment.

```ruby
# config/environments/production.rb
SimpleJson.enable_template_cache
```

The default path for templates is `app/views`, you can change it by

```ruby
SimpleJson.template_paths.append("app/simple_jsons")
# or
SimpleJson.template_paths=["app/views", "app/simple_jsons"]
```

Note that these paths should not be eager loaded cause using .rb as suffix.

SimpleJson uses ActiveSupport::JSON as the default JSON serializer. If you want to change to a module that has `#encode` and `#decode` methods, such as the Oj gem, you can do so as follows.

```ruby

# define Custom Json class
# ex. config/initializers/simple_json/json.rb
module SimpleJson
  module Json
    class Oj
      def self.encode(json)
        ::Oj.dump(json, mode: :rails)
      end

      def self.decode(json_string)
        ::Oj.load(json_string, mode: :rails)
      end
    end
  end
end

SimpleJson.json_module = SimpleJson::Json::Oj
```

## The Generator

SimpleJson extends the default Rails scaffold generator and adds some simple_json templates. If you don't need them, please configure like so.

```rb
Rails.application.config.generators.simple_json false
```

## Benchmarks

Here're the results of a benchmark (which you can find [here](https://github.com/aktsk/simple_json/blob/master/test/dummy_app/app/controllers/benchmarks_controller.rb) in this repo) rendering a collection to JSON.

```
% ./bin/benchmark.sh

SimpleJson Benchmark
ruby: 4.0.1
rails: 8.1.1
json: 2.15.2
oj: 3.16.11
----------------------

* Rendering 10 partials via render_to_string
ruby 4.0.1 (2026-01-13 revision e04267a14b) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                  jb    23.000 i/100ms
            jbuilder    30.000 i/100ms
     simple_json(oj)    40.000 i/100ms
simple_json(AS::json)
                        46.000 i/100ms
Calculating -------------------------------------
                  jb    298.518 (±23.4%) i/s    (3.35 ms/i) -      1.426k in   5.019370s
            jbuilder    255.925 (± 4.3%) i/s    (3.91 ms/i) -      1.290k in   5.052973s
     simple_json(oj)    270.192 (± 3.7%) i/s    (3.70 ms/i) -      1.360k in   5.039635s
simple_json(AS::json)
                        297.476 (±10.1%) i/s    (3.36 ms/i) -      1.518k in   5.145803s

Comparison:
                  jb:      298.5 i/s
simple_json(AS::json):      297.5 i/s - same-ish: difference falls within error
     simple_json(oj):      270.2 i/s - same-ish: difference falls within error
            jbuilder:      255.9 i/s - same-ish: difference falls within error


* Rendering 100 partials via render_to_string
ruby 4.0.1 (2026-01-13 revision e04267a14b) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                  jb    19.000 i/100ms
            jbuilder    14.000 i/100ms
     simple_json(oj)    15.000 i/100ms
simple_json(AS::json)
                        26.000 i/100ms
Calculating -------------------------------------
                  jb    186.051 (±12.9%) i/s    (5.37 ms/i) -    912.000 in   5.075117s
            jbuilder    144.279 (± 2.1%) i/s    (6.93 ms/i) -    728.000 in   5.048538s
     simple_json(oj)    159.254 (± 1.9%) i/s    (6.28 ms/i) -    810.000 in   5.088178s
simple_json(AS::json)
                        249.690 (± 6.0%) i/s    (4.00 ms/i) -      1.248k in   5.017042s

Comparison:
simple_json(AS::json):      249.7 i/s
                  jb:      186.1 i/s - 1.34x  slower
     simple_json(oj):      159.3 i/s - 1.57x  slower
            jbuilder:      144.3 i/s - 1.73x  slower


* Rendering 1000 partials via render_to_string
ruby 4.0.1 (2026-01-13 revision e04267a14b) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                  jb     4.000 i/100ms
            jbuilder     2.000 i/100ms
     simple_json(oj)     2.000 i/100ms
simple_json(AS::json)
                        10.000 i/100ms
Calculating -------------------------------------
                  jb     48.691 (± 2.1%) i/s   (20.54 ms/i) -    244.000 in   5.013815s
            jbuilder     27.930 (± 3.6%) i/s   (35.80 ms/i) -    140.000 in   5.016897s
     simple_json(oj)     29.083 (± 6.9%) i/s   (34.38 ms/i) -    146.000 in   5.039076s
simple_json(AS::json)
                         99.792 (± 7.0%) i/s   (10.02 ms/i) -    500.000 in   5.037716s

Comparison:
simple_json(AS::json):       99.8 i/s
                  jb:       48.7 i/s - 2.05x  slower
     simple_json(oj):       29.1 i/s - 3.43x  slower
            jbuilder:       27.9 i/s - 3.57x  slower
```

## Migrating from Jbuilder

When migrating from Jbuilder, you can include `Migratable` in controller for migrating mode.

```
include SimpleJson::SimpleJsonRenderable
include SimpleJson::Migratable
```

In migrating mode

- Comparision will be performed for simple_json and ActionView render(Jbuilder) result.
- simple_json partials not found will use Jbuilder partial as an alternative.

Note that render will be performed twice, so using it in production mode is not recommended.

## Contributing

Pull requests are welcome on GitHub at <https://github.com/aktsk/simple_json>.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
