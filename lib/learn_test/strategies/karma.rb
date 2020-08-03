# frozen_string_literal: true

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
        run_karma

        return unless @missing_karma

        puts 'Installing local karma dependencies...'.green
        run_install('npm install')

        run_karma
      end

      def output
        @output ||= File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
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

      private

      def run_karma
        karma_config = LearnTest::FileFinder.location_to_dir('strategies/karma/karma.conf.js')
        Open3.popen3("karma start #{karma_config}") do |stdin, stdout, stderr, wait_thr|
          while out = stdout.gets do
            puts out
          end

          while err = stderr.gets do
            if err.include?('Cannot find local Karma!')
              die_missing_local_karma if @missing_karma
              @missing_karma = true
            end
            puts err
          end
        end
      end

      def die_missing_local_karma
        die("You appear to be missing karma in your local node modules. Try running `npm install`.\nIf the issue persists, make sure karma is specified as a dependency in the package.json")
      end
    end
  end
end
