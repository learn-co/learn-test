module Ironboard
  class UserIdParser
    def self.get_user_id
      parser = Ironboard::NetrcInteractor.new
      parser.user_id
    end
  end
end

