# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pub_sub/version"

Gem::Specification.new do |s|
  s.name        = "pub_sub"
  s.version     = PubSub::VERSION
  s.authors     = ["Simon Horne"]
  s.email       = ["simon@soulware.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Minimal Publisher/Subscriber}
  s.description = %q{Minimal Publisher/Subscriber}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_development_dependency "rake"

  s.add_runtime_dependency "bunny", ["= 0.7.8"]
end
