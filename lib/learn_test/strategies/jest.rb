module LearnTest
  module Strategies
    class Jest < LearnTest::Strategy
      include LearnTest::JsStrategy

      def service_endpoint
        '/e/flatiron_jest'
      end

      def detect
        return false if !js_package

        has_js_dependency?(:jest)
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
      end

      def run
        run_jest
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'jest',
              formatted_output: output,
              duration: output[:testResults][0][:endTime] - output[:startTime]
            }]
          },
          examples: output[:numTotalTestSuites],
          passing_count: output[:numPassedTests],
          failure_count: output[:numFailedTests]
        }
      end

      def output
        @output ||= File.exist?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      private

      def run_jest
        npm_install
        system("node_modules/.bin/jest --json --outputFile=.results.json")
      end

    end
  end
end
