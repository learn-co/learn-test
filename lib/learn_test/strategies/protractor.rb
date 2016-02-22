require 'open3'
require 'pry'

module LearnTest
  module Strategies
    class Protractor < LearnTest::Strategy
      def service_endpoint
        '/e/protractor'
      end

      def detect
        runner.files.include?('conf.js')
      end

      def check_dependencies
        Dependencies::Protractor.new.execute
      end

      def run
        Open3.popen3('protractor conf.js --resultJsonOutputFile .results.json') do |stdin, stdout, stderr, wait_thr|
          while line = stdout.gets do
            if line.include?('Error: Cannot find module')
              @modules_missing = true
            end
            puts line
          end

          while stderr_line = stderr.gets do
            if stderr_line.include?('ECONNREFUSED')
              @webdriver_not_running = true
            end
            puts stderr_line
          end

          if wait_thr.value.exitstatus != 0
            if @webdriver_not_running
              die('Webdriver manager does not appear to be running. Run `webdriver-manager start` to start it.')
            end

            if @modules_missing
              die("You appear to be missing npm dependencies. Try running `npm install`\nIf the issue persists, check the package.json")
            end
          end
        end
      end

      def output
        File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'protractor',
              formatted_output: output,
              duration: 0.0
            }]
          },
          tests: 0,
          errors: 0,
          failures: 0
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end
    end
  end
end
