require_relative 'rspec/runner'

module LearnTest
  module Strategies
    class Rspec < LearnTest::Strategy
      def run(runner)
        LearnTest::RSpec::Runner.run(runner.repo, ARGV)
      end
    end
  end
end
