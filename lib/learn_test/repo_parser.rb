# frozen_string_literal: true

require 'git'

module LearnTest
  class RepoParser
    def self.get_repo
      begin
        repo = Git.open(FileUtils.pwd)
      rescue
        puts "You don't appear to be in a Learn lesson's directory. Please enter 'learn open' or cd to an appropriate directory and try again."
        die
      end

      if url = repo.remote.url
        url.match(/(?:https?:\/\/|git@).*\/(.+?)(?:\.git)?$/)[1]
      else
        puts "You don't appear to be in a Learn lesson's directory. Please enter 'learn open' or cd to an appropriate directory and try again."
        die
      end
    end

    def self.die
      exit
    end
  end
end
