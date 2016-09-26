require 'socket'

module LearnTest::Ide
  IDE_USER_HOME = "/home/#{ENV['USER']}"

  class Client
    def browser_open(url)
      File.open("#{ide_user_home}/.custom_commands.log", 'a') do |f|
        f.puts({ command: 'browser_open', url: url }.to_json)
      end
    end

    private

    def ide_user_home
      IDE_USER_HOME
    end
  end
end
