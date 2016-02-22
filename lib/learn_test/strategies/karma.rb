module LearnTest
  module Strategies
    class Karma < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_karma'
      end

      def detect
        runner.files.include?('karma.conf.js')
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
        Dependencies::Karma.new.execute
      end

      def run
        karma_config = LearnTest::FileFinder.location_to_dir('strategies/karma/karma.conf.js')

        Open3.popen3("karma start #{karma_config}") do |stdin, stdout, stderr, wait_thr|
          while out = stdout.gets do
            puts out
          end

          while err = stderr.gets do
            if err.include?('Cannot find local Karma!')
              @missing_karma = true
            end
            puts err
          end

          if wait_thr.value.exitstatus != 0
            if @missing_karma
              die("You appear to be missing karma in your local node modules. Try running `npm install`.\nIf the issue persists, check if karma is specified as a dependency in the package.json.")
            end
          end
        end
      end

      def output
        @output ||= File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'karma',
              formatted_output: output,
              duration: 0.0
            }]
          },
          examples: output[:summary][:success] + output[:summary][:failed],
          passing_count: output[:summary][:success],
          failure_count: output[:summary][:failed]
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end
    end
  end
end
