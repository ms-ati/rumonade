# encoding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)
require 'rumonade/typeclass/version'

Gem::Specification.new do |s|
  s.name          = 'rumonade-typeclass'
  s.version       = Rumonade::Typeclass::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'MIT'
  s.authors       = ['Marc Siegel']
  s.email         = ['marc@usainnov.com']
  s.homepage      = 'https://github.com/ms-ati/rumonade'
  s.summary       = 'TypeClass gives you polymorphism over Ruby classes without modification nor monkey-patching'
  s.description   = 'TypeClass is Rumonade\'s encoding of _type classes_ in Ruby for ad-hoc and higher-kinded polymorphism'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # Specify any dependencies here
  s.add_development_dependency 'rake',  '~> 10.3.0'
  s.add_development_dependency 'rspec', '~> 3.1.0'
end
