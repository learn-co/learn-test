module LearnTest
  class Strategy
    def username
      @username ||= LearnTest::UsernameParser.get_username
    end

    def user_id
      @user_id ||= LearnTest::UserIdParser.get_user_id
    end
  end
end
