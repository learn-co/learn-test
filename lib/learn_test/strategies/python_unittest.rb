require_relative 'python_unittest/requirements_checker'
require_relative 'python_unittest/nose_installer'
require_relative 'python_unittest/runner'

module LearnTest
  module Strategies
    class PythonUnittest < LearnTest::Strategy
      def run
        LearnTest::PythonUnittest::Runner.run(repo, ARGV)
      end
    end
  end
end
