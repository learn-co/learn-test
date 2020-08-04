# frozen_string_literal: true

module LearnTest
  class UsernameParser
    def self.get_username
      parser = LearnTest::NetrcInteractor.new
      username = parser.username
      user_id = parser.user_id

      if !LearnTest::LearnOauthTokenParser.get_learn_oauth_token && (!username || user_id == 'none')
        print 'Enter your github username: '
        username = $stdin.gets.strip
        user_id = LearnTest::GithubInteractor.get_user_id_for(username)
        parser.write(username, user_id)
      end

      username
    end
  end
end
