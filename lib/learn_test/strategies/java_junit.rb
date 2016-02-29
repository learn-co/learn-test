module LearnTest
  module Strategies
    class JavaJunit < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_java_junit'
      end

      def detect
        runner.files.any? { |f| f.match(/^javacs\-lab\d+$/) }
      end

      def check_dependencies
        Dependencies::Java.new.execute
        Dependencies::Ant.new.execute
      end

      def run
        run_ant
        make_json
      end

      private

      def run_ant

      end
    end
  end
end
