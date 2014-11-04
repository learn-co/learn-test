module Ironboard
  class UsernameParser
    def self.get_username
      parser = Ironboard::NetrcInteractor.new
      username = parser.username

      if !username
        print "Enter your github username: "
        username = gets.strip
        user_id = Ironboard::GithubInteractor.get_user_id_for(username)
        parser.write(username, user_id)
      end

      username
    end
  end
end

