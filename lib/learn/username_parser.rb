module Learn
  class UsernameParser
    def self.get_username
      parser = Learn::NetrcInteractor.new
      username = parser.username
      user_id = parser.user_id

      if !username || user_id == 'none'
        print "Enter your github username: "
        username = gets.strip
        user_id = Learn::GithubInteractor.get_user_id_for(username)
        parser.write(username, user_id)
      end

      username
    end
  end
end

