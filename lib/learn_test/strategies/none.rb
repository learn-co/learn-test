# frozen_string_literal: true

module LearnTest
  module Strategies
    class None < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_none'
      end

      def run
        puts <<~MSG
          This directory doesn't appear to have any specs in it, so there’s no test to run.

          If you are working on Canvas, this assignment has been submitted. You can resubmit by running `learn test` again.
        MSG
      end

      def results
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{ framework: 'none' }]
          },
          examples: 0,
          passing_count: 0,
          pending_count: 0,
          failure_count: 0,
          failure_descriptions: ''
        }
      end
    end
  end
end
