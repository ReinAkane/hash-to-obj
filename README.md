## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash-to-obj'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hash-to-obj

## Usage

Once installed you can simply call `objectify` on a hash to objectify it!

```ruby
my_hash = { a: 1, b: 2, c: 3 }
objectify my_hash
my_hash.a # 1
my_hash.b = "b" # { a: 1, b: "b", c: 3 }
```

If you add new elements to the hash it will not currently create helper methods.
