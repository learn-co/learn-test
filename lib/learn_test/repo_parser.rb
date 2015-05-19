require 'git'

module LearnTest
  class RepoParser
    def self.get_repo
      begin
        repo = Git.open(FileUtils.pwd)
      rescue
        puts "Not a valid Git repository"
        die
      end

      url = repo.remote.url
      url.match(/(?:https:\/\/|git@).*\/(.+?)(?:\.git)?$/)[1]
    end

    def self.die
      exit
    end
  end
end

