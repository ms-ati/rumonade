# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rumonade/version"

Gem::Specification.new do |s|
  s.name        = "rumonade"
  s.version     = Rumonade::VERSION
  s.authors     = ["Marc Siegel"]
  s.email       = ["msiegel@usainnov.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "rumonade"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "test-unit"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rr"
end
