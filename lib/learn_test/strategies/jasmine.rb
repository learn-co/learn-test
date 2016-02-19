require_relative 'jasmine/phantom_checker'
require_relative 'jasmine/initializer'
require_relative 'jasmine/runner'

module LearnTest
  module Strategies
    class Jasmine < LearnTest::Strategy
      def run(runner)
        LearnTest::Jasmine::Runner.run(runner.repo, runner.jasmine_options)
      end
    end
  end
end
