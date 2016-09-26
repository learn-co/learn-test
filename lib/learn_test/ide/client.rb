require 'socket'

module LearnTest::Ide
  IDE_USER_HOME = "/home/#{ENV['USER']}"

  class Client
    def browser_open(url)
      File.open("#{ide_user_home}/.fs_changes.log", 'a') do |f|
        f.puts "chrome BROWSER_OPEN #{url}"
      end
    end

    private

    def ide_user_home
      IDE_USER_HOME
    end
  end
end
