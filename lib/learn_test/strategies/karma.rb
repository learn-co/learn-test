module LearnTest
  module Strategies
    class Karma < LearnTest::Strategy
      def service_endpoint
        '/e/karma'
      end

      def detect
        runner.files.include?('karma.conf.js')
      end

      def check_dependencies
        Dependencies::Karma.new.execute
      end

      def run
        Open3.popen3('karma start') do |stdin, stdout, stderr, wait_thr|
          while out = stdout.gets do
            puts out
          end

          while err = stderr.gets do
            if err.include?('Cannot find local Karma!')
              @missing_karma = true
            end
            puts err
          end

          if wait_thr. value.exitstatus != 0
            if @missing_karma
              die("You appear to be missing karma in your npm dependencies. Try running `npm install`\nIf the issue persists, check if karma is in the package.json.")
            end
          end
        end
      end

      def output
        {}
      end
    end
  end
end