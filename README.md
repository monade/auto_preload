![Tests](https://github.com/monade/auto_preload/actions/workflows/test.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/auto_preload.svg)](https://badge.fury.io/rb/auto_preload)

# Auto Preload

A gem to parse and run `preload`/`includes`/`eager_load` on your model from a JSON::API formatted string.

** This gem is WIP **

## Installation

Add the gem to your Gemfile

```ruby
gem 'paramoid'
```

and run the `bundle install` command.

## Usage

```ruby
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

User.auto_preload('*') # preload(:articles, :comments)
User.auto_preload('articles.*') # preload(articles: [:user, :comments])
```

**TODO** Add more examples.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

About Monade
----------------

![monade](https://monade.io/wp-content/uploads/2021/06/monadelogo.png)

auto_preload is maintained by [mònade srl](https://monade.io/en/home-en/).

We <3 open source software. [Contact us](https://monade.io/en/contact-us/) for your next project!
