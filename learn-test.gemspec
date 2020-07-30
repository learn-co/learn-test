# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_test/version'

Gem::Specification.new do |spec|
  spec.name          = "learn-test"
  spec.version       = LearnTest::VERSION
  spec.authors       = ["Flatiron School"]
  spec.email         = ["learn@flatironschool.com"]
  spec.summary       = %q{Runs RSpec, Jasmine, Karma, Mocha, and Python Pytest Test builds and pushes JSON output to Learn.}
  spec.homepage      = "https://github.com/learn-co/learn-test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "bin"]
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 13.0.1"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_runtime_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "netrc", "~> 0.11.0"
  spec.add_runtime_dependency "git", "~> 1.2"
  spec.add_runtime_dependency "oj", "~> 2.9"
  spec.add_runtime_dependency "faraday", "~> 1.0"
  spec.add_runtime_dependency "crack", "~> 0.4.3"
  spec.add_runtime_dependency "jasmine", "~> 2.6.0", ">= 2.6.0"
  spec.add_runtime_dependency "jasmine-core", "< 2.99.1"
  spec.add_runtime_dependency "colorize", "~> 0.8.1"
  spec.add_runtime_dependency "webrick", "~> 1.3.1", ">= 1.3.1"
  spec.add_runtime_dependency "rainbow", "= 1.99.2"
end
