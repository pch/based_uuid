# BasedUUID: double-clickable, URL-friendly UUIDs for your Rails models

[![Build Status](https://github.com/pch/based_uuid/workflows/Tests/badge.svg)](https://github.com/pch/based_uuid/actions) [![Gem Version](https://badge.fury.io/rb/based_uuid.svg)](https://badge.fury.io/rb/based_uuid)


Generate “double-clickable”, URL-friendly UUIDs with (optional) prefixes:

```
user_4yoiald3wfbvpeu2sbsk7cssdi
acc_ejwqg7b3gvaphiylb25xq545tm
```

This gem encodes UUID primary keys into 26-character lowercase strings using [Crockford’s base32](https://www.crockford.com/base32.html) encoding. The optional prefix helps you identify the model it represents.

BasedUUID assumes that you have a [UUID primary key](https://guides.rubyonrails.org/v5.0/active_record_postgresql.html#uuid) (`id`) in your ActiveRecord model. It doesn’t affect how your ActiveRecord primary key UUIDs are stored in the database. Prefix and base32 encoding are only used for presentation.

## Installation

Add this line to your `Gemfile`:

```ruby
gem "based_uuid"
```

## Usage

Add the following line to your model class:

```ruby
class BlogPost < ApplicationRecord
  has_based_uuid prefix: :bpo
end

post = BlogPost.last
post.based_uuid #=> bpo_3ah4veflijgy7de6bflk7k4ld4
post.based_uuid(prefix: false) #=> 3ah4veflijgy7de6bflk7k4ld4
```

### Lookup

BasedUUID includes a `find_by_based_uuid` model method to look up records:

```ruby
BlogPost.find_by_based_uuid("bpo_3ah4veflijgy7de6bflk7k4ld4")

# or without the prefix:
BlogPost.find_by_based_uuid("3ah4veflijgy7de6bflk7k4ld4")

# there’s also the bang version:
BlogPost.find_by_based_uuid!("3ah4veflijgy7de6bflk7k4ld4")
```

### Generic lookup

The gem provides a generic lookup method to help you find the correct model for the UUID, based on prefix:

```ruby
BasedUUID.find("bpo_3ah4veflijgy7de6bflk7k4ld4")
#=> #<BlogPost>
BasedUUID.find("acc_ejwqg7b3gvaphiylb25xq545tm")
#=> #<Account>
```

**⚠️ NOTE:** Rails lazy-loads models in the development environment, so this method won’t know about your models until you’ve referenced them at least once. If you’re using this method in a Rails console, you’ll need to run `BlogPost` (or any other model) before you can use it.

### BasedUUID as default URL identifiers

BasedUUID aims to be unintrusive and it doesn’t affect how Rails URLs are generated, so if you want to use it as default URL param, add this to your model:

```ruby
def to_param
  based_uuid
end
```

* * *

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pch/based_uuid.

### Credits

This gem is heavily inspired by [Stripe IDs](https://stripe.com/docs/api) and the [prefixed_ids](https://github.com/excid3/prefixed_ids/tree/master) gem by Chris Oliver.

Parts of the base32 encoding code are borrowed from the [ulid gem](https://github.com/rafaelsales/ulid) by Rafael Sales.
