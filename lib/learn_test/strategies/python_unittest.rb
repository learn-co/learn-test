require_relative 'python_unittest/requirements_checker'
require_relative 'python_unittest/nose_installer'

module LearnTest
  module Strategies
    class PythonUnittest < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_unittest'
      end

      def detect
        runner.files.any? {|f| f.match(/.*.py$/) }
      end

      def check_dependencies
        LearnTest::PythonUnittest::RequirementsChecker.check_installation
        LearnTest::PythonUnittest::NoseInstaller.install
      end

      def run
        system("nosetests #{options[:argv].join(' ')} --verbose --with-json --json-file='./.results.json'")
      end

      def output
        @output ||= Oj.load(File.read('.results.json'), symbol_keys: true)
      end

      def results
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'unittest',
              formatted_output: output,
              duration: calculate_duration
            }]
          },
          examples: output[:stats][:total],
          passing_count: output[:stats][:passes],
          pending_count: output[:stats][:skipped],
          failure_count: output[:stats][:errors],
          failure_descriptions: concat_failure_descriptions
        }
      end

      def cleanup
        FileUtils.rm('.results.json')
      end

      private

      def calculate_duration
        output[:results].map do |example|
          example[:time]
        end.inject(:+)
      end

      def concat_failure_descriptions
        output[:results].select do |example|
          example[:type] == 'failure'
        end.map { |ex| ex[:tb] }.join(';')
      end
    end
  end
end
