require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :test_dsl do
  ruby "spec/hash-to-obj_helper.rb"
end

task :default => [:spec, :test_dsl]
