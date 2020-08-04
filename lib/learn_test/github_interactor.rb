# frozen_string_literal: true

require 'open-uri'

module LearnTest
  class GithubInteractor
    attr_reader :username, :user_id

    def self.get_user_id_for(username)
      new(username).get_user_id
    end

    def initialize(username)
      @username = username
    end

    def get_user_id
      @user_id ||= Oj.load(
        open("https://api.github.com/users/#{username}").read,
        symbol_keys: true
      )[:id]
    end
  end
end
