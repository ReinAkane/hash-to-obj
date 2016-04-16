# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash-to-obj/version'

Gem::Specification.new do |spec|
  spec.name          = "hash-to-obj"
  spec.version       = HashToObj::VERSION
  spec.authors       = ["Sam Maxwell"]
  spec.email         = ["raindropenter@gmail.com"]

  spec.summary       = %q{Simple Ruby gem to objectify hashes}
  spec.description   = "Call 'objectify my_hash' to add accessor methods to "\
                       "my_hash based on the keys currently in the has."
  spec.homepage      = "https://github.com/ReinAkane/hash-to-obj"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", ">= 0"
end
