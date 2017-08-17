# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_test/version'

Gem::Specification.new do |spec|
  spec.name          = "learn-test"
  spec.version       = LearnTest::VERSION
  spec.authors       = ["Flatiron School"]
  spec.email         = ["learn@flatironschool.com"]
  spec.summary       = %q{Runs RSpec, Jasmine, Karma, Mocha, and Python Unit Test builds and pushes JSON output to Learn.}
  spec.homepage      = "https://github.com/learn-co/learn-test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "bin"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "netrc", "~> 0.11.0"
  spec.add_runtime_dependency "git", "~> 1.2"
  spec.add_runtime_dependency "oj", "~> 2.9"
  spec.add_runtime_dependency "faraday", "~> 0.9"
  spec.add_runtime_dependency "crack", "~> 0.4.3"
  spec.add_runtime_dependency "jasmine", "~> 2.6.0", '>= 2.6.0'
  spec.add_runtime_dependency "colorize", "~> 0.8.1"
  spec.add_runtime_dependency "webrick", "~> 1.3.1", '>= 1.3.1'
  spec.add_runtime_dependency "rainbow", "= 1.99.2"
  spec.add_runtime_dependency "selenium-webdriver", "~> 2.52.0", '>= 2.52.0'
end
