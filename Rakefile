require 'bundler/gem_tasks'
require 'rake/clean'
require 'rake/testtask'
require 'rspec/core/rake_task'

# Default task for `rake` is to run both rspec and test-unit
task :default => [:spec, :test]

# Use default rspec rake task
RSpec::Core::RakeTask.new

# Port older tests to rspec
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

# Configure `rake clobber` to delete all generated files
CLOBBER.include('pkg', 'doc', 'coverage')
