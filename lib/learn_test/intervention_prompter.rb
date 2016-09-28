require 'socket'

module LearnTest
  class InterventionPrompter
    attr_reader :results, :repo, :token, :profile

    HISTORY_PATH = "#{Dir.pwd}/.learn_history"
    BASE_URL = 'http://localhost:3000'
    PROMPT_ENDPOINT = "/api/cli/prompt.json"

    def initialize(test_results, repo, token, profile)
      @results = test_results
      @repo = repo
      @token = token
      @profile = profile
    end

    def execute
      ignore_history
      ask_a_question if ask_a_question_triggered?
    end

    private

    def ask_a_question
      response = ''
      until response == 'y' || response == 'n'
        puts <<-PROMPT
   /||
  //||
  // ||
  ||||||||||
    || //   Would you like to talk to a Learn Expert?
    ||//
    ||/
   PROMPT
      print '(y/n): '
      response = STDIN.gets.chomp.downcase
      end

      if response == 'y'
        browser_open(ask_a_question_url)
      else
        print 'Ok, happy learning!'
      end
    end

    def ask_a_question_url
      history = read_history
      uuid = history["uuid"]

      base_url + "/lessons/current?question_id=new&cli_event=#{uuid}"
    end

    def ask_a_question_triggered?
      return false unless profile.should_trigger?
      return false if already_triggered?
      return false if windows_environment?
      return false if all_tests_passing?

      intervention_data = get_intervention_data["payload"]
      write_history(intervention_data)
      intervention_data["aaq_trigger"]
    end

    def already_triggered?
      history = read_history
      history["aaq_trigger"] == true
    end

    def all_tests_passing?
      results[:failure_count] == 0
    end

    def connection
      @connection ||= Faraday.new(url: base_url) do |faraday|
        faraday.adapter(Faraday.default_adapter)
      end
    end

    def intervention_url
      prompt_endpoint + "?repo_name=#{repo}"
    end

    def get_intervention_data
      begin
        response = connection.get do |req|
          req.url(intervention_url)
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = "Bearer #{token}"
      end
        JSON.parse(response.body)
      rescue Faraday::ConnectionFailed
        {
          "payload" =>
            default_payload
        }
      end
    end

    def default_payload
      {
        "aaq_trigger" => false,
        "uuid" => ''
      }
    end

    def read_history
      if File.exists?(history_path)
        JSON.parse(File.read(history_path))
      else
        default_payload
      end
    end

    def write_history(history)
      f = File.open(history_path, 'w+')
      f.write(history.to_json)
      f.close
    end

    def ignore_history
      File.open('.git/info/exclude', 'a+') do |f|
        contents = f.read
        unless contents.match(/\.learn_history/)
          f.puts('.learn_history')
        end
      end
    end

    def browser_open(url)
      if ide_environment?
        ide_client.browser_open(url)
      elsif linux_environment?
        `xdg-open "#{url}"`
      else
        `open "#{url}"`
      end
    end

    def ide_client
      @ide_client ||= LearnTest::Ide::Client.new
    end

    def ide_environment?
      Socket.gethostname.end_with? '.students.learn.co'
    end

    def linux_environment?
      !!RUBY_PLATFORM.match(/linux/)
    end

    def windows_environment?
      !!RUBY_PLATFORM.match(/mswin|mingw|cygwin/)
    end

    def history_path
      HISTORY_PATH
    end

    def base_url
      BASE_URL
    end

    def prompt_endpoint
      PROMPT_ENDPOINT
    end

  end
end
