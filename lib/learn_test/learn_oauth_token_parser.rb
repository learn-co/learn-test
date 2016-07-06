module LearnTest
  class LearnOauthTokenParser
    def self.get_learn_oauth_token
      parser = LearnTest::NetrcInteractor.new(machine: 'learn-config')
      parser.user_id
    end
  end
end
