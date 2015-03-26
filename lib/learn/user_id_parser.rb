module Learn
  class UserIdParser
    def self.get_user_id
      parser = Learn::NetrcInteractor.new
      parser.user_id
    end
  end
end

