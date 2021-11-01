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
SimpleJson templates are simply lambda objects that return data(Hashs or Arrays) for json.
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

Cache helpers of jbuilder is similar.
```ruby
cache! key, options do
  data_to_cache
end
```

Cache helpers uses `Rails.cache` to cache, so Multiple key, expiration is available. Make sure `perform_caching` is enabled.
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

## configurations
Load all templates on boot. (For production)
Tempaltes loaded will not load again, so it is not recommended in development environment.
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

SimpleJson uses Oj as json serializer by default. Modules with `#encode` and `#decode` method can be used here.
```ruby
SimpleJson.json_module = ActiveSupport::JSON
```

## The Generator
SimpleJson extends the default Rails scaffold generator and adds some simple_json templates. If you don't need them, please configure like so.
```rb
Rails.application.config.generators.simple_json false
```

## Benchmarks
Here're the results of a benchmark (which you can find [here](https://github.com/aktsk/simple_json/blob/master/test/dummy_app/app/controllers/benchmarks_controller.rb) in this repo) rendering a collection to JSON.

### RAILS_ENV=development
```
% ./bin/benchmark.sh

* Rendering 10 partials via render_partial
Warming up --------------------------------------
                  jb   257.000  i/100ms
            jbuilder   108.000  i/100ms
         simple_json     2.039k i/100ms
Calculating -------------------------------------
                  jb      2.611k (± 7.1%) i/s -     13.107k in   5.046110s
            jbuilder      1.084k (± 3.5%) i/s -      5.508k in   5.088845s
         simple_json     20.725k (± 4.4%) i/s -    103.989k in   5.026914s

Comparison:
         simple_json:    20725.5 i/s
                  jb:     2610.5 i/s - 7.94x  (± 0.00) slower
            jbuilder:     1083.8 i/s - 19.12x  (± 0.00) slower


* Rendering 100 partials via render_partial
Warming up --------------------------------------
                  jb    88.000  i/100ms
            jbuilder    14.000  i/100ms
         simple_json   290.000  i/100ms
Calculating -------------------------------------
                  jb    928.202  (± 5.0%) i/s -      4.664k in   5.037314s
            jbuilder    137.980  (± 6.5%) i/s -    700.000  in   5.094658s
         simple_json      2.931k (± 5.2%) i/s -     14.790k in   5.060707s

Comparison:
         simple_json:     2931.1 i/s
                  jb:      928.2 i/s - 3.16x  (± 0.00) slower
            jbuilder:      138.0 i/s - 21.24x  (± 0.00) slower


* Rendering 1000 partials via render_partial
Warming up --------------------------------------
                  jb    11.000  i/100ms
            jbuilder     1.000  i/100ms
         simple_json    29.000  i/100ms
Calculating -------------------------------------
                  jb    106.150  (± 5.7%) i/s -    539.000  in   5.094255s
            jbuilder     13.012  (± 7.7%) i/s -     65.000  in   5.054016s
         simple_json    271.683  (± 5.2%) i/s -      1.363k in   5.030646s

Comparison:
         simple_json:      271.7 i/s
                  jb:      106.1 i/s - 2.56x  (± 0.00) slower
            jbuilder:       13.0 i/s - 20.88x  (± 0.00) slower
```
### RAILS_ENV=production
```
% RAILS_ENV=production ./bin/benchmark.sh

* Rendering 10 partials via render_partial
Warming up --------------------------------------
                  jb   246.000  i/100ms
            jbuilder    97.000  i/100ms
         simple_json     1.957k i/100ms
Calculating -------------------------------------
                  jb      2.611k (± 4.1%) i/s -     13.038k in   5.002304s
            jbuilder    972.031  (± 4.7%) i/s -      4.850k in   5.001200s
         simple_json     20.383k (± 3.8%) i/s -    101.764k in   4.999989s

Comparison:
         simple_json:    20382.8 i/s
                  jb:     2611.3 i/s - 7.81x  (± 0.00) slower
            jbuilder:      972.0 i/s - 20.97x  (± 0.00) slower


* Rendering 100 partials via render_partial
Warming up --------------------------------------
                  jb    90.000  i/100ms
            jbuilder    11.000  i/100ms
         simple_json   280.000  i/100ms
Calculating -------------------------------------
                  jb    883.446  (± 4.8%) i/s -      4.410k in   5.003438s
            jbuilder    119.932  (± 8.3%) i/s -    605.000  in   5.085382s
         simple_json      2.886k (± 4.2%) i/s -     14.560k in   5.054327s

Comparison:
         simple_json:     2885.7 i/s
                  jb:      883.4 i/s - 3.27x  (± 0.00) slower
            jbuilder:      119.9 i/s - 24.06x  (± 0.00) slower


* Rendering 1000 partials via render_partial
Warming up --------------------------------------
                  jb    12.000  i/100ms
            jbuilder     1.000  i/100ms
         simple_json    32.000  i/100ms
Calculating -------------------------------------
                  jb    124.627  (± 4.8%) i/s -    624.000  in   5.018515s
            jbuilder     12.710  (± 7.9%) i/s -     64.000  in   5.073018s
         simple_json    314.896  (± 3.2%) i/s -      1.600k in   5.086509s

Comparison:
         simple_json:      314.9 i/s
                  jb:      124.6 i/s - 2.53x  (± 0.00) slower
            jbuilder:       12.7 i/s - 24.78x  (± 0.00) slower
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

Pull requests are welcome on GitHub at https://github.com/aktsk/simple_json.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
