# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rubycop/version"

Gem::Specification.new do |s|
  s.name        = "rubycop"
  s.version     = Rubycop::VERSION
  s.authors     = ["Dray Lacy", "Eric Allam"]
  s.email       = ["dray@envylabs.com", "rubymaverick@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A semantic analyzer for Ruby 1.9}
  s.description = %q{A semantic analyzer for Ruby 1.9}

  s.rubyforge_project = "rubycop"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "rspec"
end
