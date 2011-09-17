require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

#require "rdoc/task"
#RDoc::Task.new do |rdoc|
#  rdoc.main = "README.rdoc"
#  rdoc.rdoc_files.include("README.rdoc", "CHANGELOG.rdoc", "lib/**/*.rb")
#end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require File.expand_path("../lib/rumonade/version", __FILE__)
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.title = "Rumonade #{Rumonade::VERSION}"
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('CHANGELOG.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end