# frozen_string_literal: true

module LearnTest
  class UserIdParser
    def self.get_user_id
      parser = LearnTest::NetrcInteractor.new
      parser.user_id
    end
  end
end
