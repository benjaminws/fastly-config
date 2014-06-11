# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'fastly/configure/version'

Gem::Specification.new do |s|
  s.name        = 'fastly-configure'
  s.version     = Fastly::Configure::VERSION
  s.authors     = ["Daily Kos", "Fastly, Inc"]
  s.email       = ["someone@dailykos.com", "support@fastly.com"]
  s.homepage    = "http://github.com/dailykos/fastly-config"
  s.summary     = %q{Client library for the Fastly acceleration system}
  s.description = %q{Client library for the Fastly acceleration system}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'fastly', '~> 1.1.1'
  s.add_dependency 'thor'
end

