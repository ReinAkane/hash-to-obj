def objectify(*_args)
  return false
end

module HashToObj
  SQUELCH_GLOBAL_WARNINGS = true
end

require_relative 'spec_helper'
require 'rspec/expectations'

include RSpec::Matchers

hash = { a: 'a' }
objectify hash

expect(hash.respond_to?(:a)).to be false

expect(objectify(1)).to eq(false)

puts "If we haven't errored out yet... this test passed! Woot"
