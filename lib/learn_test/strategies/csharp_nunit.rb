# frozen_string_literal: true

module LearnTest
  module Strategies
    class CSharpNunit < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_csharp_nunit'
      end

      def detect
        runner.files.any? { |f| f.match(/project.json/) }
      end

      def check_dependencies
        Dependencies::CSharp.new.execute
      end

      def run
        require 'crack'
        require 'json'

        system('dotnet test')
        output
        cleanup
      end

      def output
        @output ||= Crack::XML.parse(File.read('TestResult.xml'))
      end

      def results
        {
          username: username,
          github_user_id: user_id,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'nunit',
              formatted_output: output.to_json,
              duration: output['test_run']['duration']
            }]
          },
          examples: output['test_run']['total'],
          passing_count: output['test_run']['passed'],
          pending_count: output['test_run']['skipped'],
          failure_count: output['test_run']['failed'],
        }
      end

      def cleanup
        FileUtils.rm('TestResult.xml') if File.exist?('TestResult.xml')
      end
    end
  end
end
