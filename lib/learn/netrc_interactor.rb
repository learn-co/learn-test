require 'netrc'

module Learn
  class NetrcInteractor
    attr_reader :username, :user_id, :netrc

    def initialize
      @netrc = Netrc.read
      @username, @user_id = netrc["flatiron-push"]
    end

    def write(username, user_id)
      netrc["flatiron-push"] = username, user_id
      netrc.save
    end
  end
end

