# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_test/version'

Gem::Specification.new do |spec|
  spec.name          = "learn-test"
  spec.version       = LearnTest::VERSION
  spec.authors       = ["Flatiron School"]
  spec.email         = ["learn@flatironschool.com"]
  spec.summary       = %q{Runs RSpec, Karma, Mocha, and Python Pytest Test builds and pushes JSON output to Learn.}
  spec.homepage      = "https://github.com/learn-co/learn-test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "bin"]
  spec.required_ruby_version = '>= 2.5.0'
end
