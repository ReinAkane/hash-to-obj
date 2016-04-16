def objectify(*args)
  return false
end

require_relative 'spec_helper'
require 'rspec/expectations'

include RSpec::Matchers

hash = { a: "a" }
objectify hash

expect(hash.respond_to?(:a)).to be false

expect(objectify(1)).to eq(false)