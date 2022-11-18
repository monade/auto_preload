![Tests](https://github.com/monade/auto_preload/actions/workflows/test.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/auto_preload.svg)](https://badge.fury.io/rb/auto_preload)

# Auto Preload

A gem to parse and run `preload`/`includes`/`eager_load` on your model from a JSON::API include string.

## Installation

Add the gem to your Gemfile

```ruby
gem 'auto_preload'
```

and run the `bundle install` command.

## The problem
JSON::API allows API consumers to pass a query parameter, called `include`, to manually select which model associations should be resolved and returned in the output JSON.

This means that in your controller, you may have a dilemma:
* If the consumer requests an association that is not preloaded, Rails will run (N+1 queries)[https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations], slowing down the response
* You can't know, beforehand, which association may be requested by the consumer, since it's parametric
* You can just preload every possible association, but you'll end up making a lot of extra (redundant) queries in most cases.

This gem tries to fix this by parsing the `include` parameter and transforming it to a `preload`, `includes` or `eager_load` call in the model.

## Usage
This gem adds to ActiveRecord classes a couple of utility methods that will help to preload associations.

To start using it, simply pass a (JSON::API include string)[https://jsonapi.org/format/#fetching-includes] to the `auto_preload` class method of a model, and it will resolve it.

Here's an example:
```ruby
# Models declaration
class User < ApplicationRecord
  has_many :articles
  has_many :comments
end

class Comment < ApplicationRecord
  belongs_to :user
end

class Article < ApplicationRecord
  belongs_to :user
  has_many :comments
end

# Now calling auto_preload on User
User.auto_preload('*') # Equivalent to preload(:articles, :comments)
User.auto_preload('articles.*') # Equivalent to preload(articles: [:user, :comments])
```

The same works also with `eager_load` and `includes`:
```ruby
User.auto_eager_load('*') # Equivalent to eager_load(:articles, :comments)
User.auto_includes('*') # Equivalent to includes(:articles, :comments)
```

### Caveats: the `**` resolver
You can also use the keyword `**`, however it may take you to a loop.

For instance in this case, it would raise an error:
```ruby
User.auto_preload('**') # Raises "Too many iterations reached (101 of 100)"
```
Since `User` resolves `:articles`, but `Article` declares `belongs_to :user`.

To solve this you can whitelist the associations you want to preload:
```ruby
class Article < ApplicationRecord
  self.auto_preloadable = [:comments]
  belongs_to :user
  has_many :comments
end

class Comment < ApplicationRecord
  self.auto_preloadable = []
  belongs_to :user
end
```

Now you can safely use auto_preload:
```ruby
User.auto_preload('**') # Equivalent to preload(:comments, articles: :comments)
```

### Adapters
By default, the resolution of the expressions passed to `auto_preload` methods is resolved by the (ActiveRecord Adapter)[https://github.com/monade/auto_preload/blob/master/lib/auto_preload/adapters/active_record.rb].

An Adapter is simply a class that, given a model, returns the list of the associations that can be preloaded.

The ActiveRecord Adapter uses `reflect_on_all_associations` to get this list.

In many circumstances, you don't want this. For instance, if you use `ActiveModelSerializers` gem, you want to resolve only associations that are declared in the serializer.

To do so, just change the default adapter using an initializer, in `config/initializers/auto_preload.rb`:
```ruby
AutoPreload.config.adapter = AutoPreload::Adapters::Serializer.new
```

Of course, you can also declare your custom Adapters, simply creating a class that implements the method `resolve_preloadables(model, options = {})` and returns a list of associations.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

About Monade
----------------

![monade](https://monade.io/wp-content/uploads/2021/06/monadelogo.png)

auto_preload is maintained by [mònade srl](https://monade.io/en/home-en/).

We <3 open source software. [Contact us](https://monade.io/en/contact-us/) for your next project!
