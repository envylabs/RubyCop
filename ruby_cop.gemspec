# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_cop/version"

Gem::Specification.new do |s|
  s.name        = "ruby_cop"
  s.version     = RubyCop::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dray Lacy", "Eric Allam"]
  s.email       = ["dray@envylabs.com", "eric@envylabs.com"]
  s.homepage    = ""
  s.summary     = %q{Statically analyze Ruby and neutralize nefarious code}
  s.description = %q{Statically analyze Ruby and neutralize nefarious code}

  s.rubyforge_project = "ruby_cop"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.3.0'
  s.add_development_dependency 'geminabox'
end
