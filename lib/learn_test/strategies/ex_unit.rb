module LearnTest
  module Strategies
    class ExUnit < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_ex_unit'
      end

      def detect
        runner.files.include?('mix.exs')
      end

      def run
        system("mix test --formatter=LearnCo.ExUnit.JSONFormatter")
      end

      def output
        contents = File.exists?('.results.json') && Oj.load(File.read('.results.json'), symbol_keys: true)
        LearnTest::ExUnitOutput.new(contents)
      end


      def results
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'ex_unit',
              formatted_output: output.raw,
              duration: output.duration,
            }]
          },
          examples: output.example_count,
          passing_count: output.passing_count,
          pending_count: output.pending_count,
          failure_count: output.failure_count,
          failure_descriptions: output.failures,
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end
    end
  end
end
