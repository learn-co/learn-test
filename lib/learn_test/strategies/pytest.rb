# frozen_string_literal: true

require 'crack'
require_relative 'pytest/requirements_checker'

module LearnTest
  module Strategies
    class Pytest < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_pytest'
      end

      def detect
        test_files.count > 0
      end

      def check_dependencies
        LearnTest::Pytest::RequirementsChecker.check_installation
      end

      def run
        system("python -m pytest #{options[:argv].join(' ')} --junitxml='./.results.xml'")
      end

      def output
        @output ||= Crack::XML.parse(File.read('.results.xml'))['testsuite']
      end

      def test_files
        # pytest will run all files of the form test_*.py or *_test.py
        @test_files ||= Dir.glob('**/test_*.py') + Dir.glob('**/*_test.py')
      end

      def results
        failed_count = output['failures'].to_i + output['errors'].to_i
        skipped_count = output['skips'].to_i
        passed_count = output['tests'].to_i - failed_count - skipped_count
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'pytest',
              formatted_output: output.to_json,
              duration: output['time']
            }]
          },
          examples: output['tests'].to_i,
          passing_count: passed_count,
          pending_count: skipped_count,
          failure_count: failed_count,
          failure_descriptions: concat_failure_descriptions
        }
      end

      def cleanup
        FileUtils.rm('.results.xml')
      end

      private

      def calculate_duration
        output[:results].map do |example|
          example[:time]
        end.inject(:+)
      end

      def concat_failure_descriptions
        # if there is a single test the `testcase` xml parse turns out a hash
        #   instead of an array with a single hash. this will make sure single
        #   tests have the same output structure (Array) as multiple tests
        output['testcase'] = [output['testcase']].flatten

        output['testcase'].reduce([]) do |errors, example|
          if example.has_key?('failure')
            errors << example.map { |k, v| "#{k}: #{v}" }
          end
          errors
        end
      end
    end
  end
end
