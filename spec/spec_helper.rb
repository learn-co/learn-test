# frozen_string_literal: true

require 'aruba/rspec'
require 'digest'
require 'simplecov'

SimpleCov.start

require_relative '../lib/learn_test'

support_dir = File.join('./', 'spec', 'support', '**', '*.rb')
Dir.glob(support_dir).each { |f| require f }

RSpec.configure do |config|
  # config.filter_run focus: true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
