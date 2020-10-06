# frozen_string_literal: true

describe LearnTest::Strategies::None do
  describe '#run' do
    it 'prints a message' do
      strategy = LearnTest::Strategies::None.new(double(:runner, options: {}))

      msg = <<~MSG
        This directory doesn't appear to have any specs in it, so there’s no test to run.

        If you are working on Canvas, this assignment has been submitted. You can resubmit by running `learn test` again.
      MSG

      expect { strategy.run }.to output(msg).to_stdout
    end
  end

  describe '#results' do
    it 'contains the appropriate attributes' do
      user_id = rand(1000..9999)
      username = "test-username-#{user_id}"
      oauth_token = "test-token-#{user_id}"
      repo = double(:repo)

      runner = LearnTest::Runner.new(repo, {})
      strategy = LearnTest::Strategies::None.new(runner)

      expect(LearnTest::UsernameParser).to receive(:get_username)
        .and_return(username)

      expect(LearnTest::UserIdParser).to receive(:get_user_id)
        .and_return(user_id)

      expect(LearnTest::LearnOauthTokenParser).to receive(:get_learn_oauth_token)
        .and_return(oauth_token)


      expect(strategy.results).to eq(
        username: username,
        github_user_id: user_id,
        learn_oauth_token: oauth_token,
        repo_name: repo,
        build: {
          test_suite: [{ framework: 'none' }]
        },
        examples: 0,
        passing_count: 0,
        pending_count: 0,
        failure_count: 0,
        failure_descriptions: ''
      )
    end
  end
end
