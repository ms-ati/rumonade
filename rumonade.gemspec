# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rumonade/version'

Gem::Specification.new do |s|
  s.name        = 'rumonade'
  s.version     = Rumonade::VERSION
  s.authors     = ['Marc Siegel']
  s.email       = ['marc@usainnov.com']
  s.homepage    = 'http://github.com/ms-ati/rumonade'
  s.summary     = 'A Scala-inspired Monad library for Ruby'
  s.description = 'A Scala-inspired Monad library for Ruby, aiming to share the most common idioms for folks working in both languages. Includes Option, Array, etc.'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'coveralls'
end
