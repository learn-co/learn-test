require 'yaml'

module LearnTest
  class Runner
    attr_reader :repo, :options
    SERVICE_URL = 'http://ironbroker-v2.flatironschool.com'
    PROFILE_PATH = "#{ENV['HOME']}/.learn_profile"
    HISTORY_PATH = "#{Dir.pwd}/.learn_history"

    def initialize(repo, options = {})
      @repo = repo
      @options = options
      die if !strategy
    end

    def run
      strategy.check_dependencies
      strategy.configure
      strategy.run
      if !help_option_present? && strategy.push_results? && !local_test_run?
        push_results(strategy)
      end
      results = strategy.results
      strategy.cleanup unless keep_results?

      ask_a_question(results)
    end


    def ask_a_question(results)
      if ask_a_question_triggered?(results)
        history = read_history
        uuid = history["uuid"]

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
          `open "http://localhost:3000/lessons/current?question_id=new&cli_event=#{uuid}"`
        else
          'Ok, happy learning!'
        end
      end
    end

    def read_history
      if File.exists?(history_path)
        JSON.parse(File.read(history_path))
      else
        { "aaq" => false,
          "uuid" => ''
        }
      end
    end

    def write_history(history)
      f = File.open(history_path, 'w+')
      f.write(history.to_json)
      f.close
    end

    def ask_a_question_triggered?(results)
      history = read_history
      return false if history["aaq"] == true
      return false if results[:failure_count] == 0

      intervention_data = get_api_cli_aaq["payload"]
      write_history(intervention_data)
      intervention_data["aaq_trigger"]
    end

    def get_api_cli_aaq
      local_connection ||= Faraday.new(url: 'http://localhost:3000') do |faraday|
        faraday.adapter(Faraday.default_adapter)
      end

      begin
        response = local_connection.get do |req|
          req.url("/api/cli/aaq.json?repo_name=#{repo}")
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = "Bearer #{strategy.learn_oauth_token}"

        end

        JSON.parse(response.body)
      rescue Faraday::ConnectionFailed
        { "payload":
          {
            "aaq_trigger": false
          }
        }
      end
    end

    def files
      @files ||= Dir.entries('.')
    end

    def keep_results?
      @keep_results ||= options[:keep] || !!options.delete('--keep')
    end

    def strategy
      @strategy ||= strategies.map{ |s| s.new(self) }.detect(&:detect)
    end

    private

    def history_path
      HISTORY_PATH
    end

    def profile_path
      PROFILE_PATH
    end

    def augment_results!(results)
      if File.exist?("#{FileUtils.pwd}/.learn")
        dot_learn = YAML.load(File.read("#{FileUtils.pwd}/.learn"))

        if !dot_learn['github'].nil?
          results[:github] = dot_learn['github']
        end
      end
    end

    def connection
      @connection ||= Faraday.new(url: SERVICE_URL) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def strategies
      [
        LearnTest::Strategies::CSharpNunit,
        LearnTest::Strategies::Jasmine,
        LearnTest::Strategies::GreenOnion,
        LearnTest::Strategies::Rspec,
        LearnTest::Strategies::Karma,
        LearnTest::Strategies::Protractor,
        LearnTest::Strategies::JavaJunit,
        LearnTest::Strategies::Mocha,
        LearnTest::Strategies::PythonUnittest
      ]
    end

    def push_results(strategy)
      results = strategy.results
      augment_results!(results)

      begin
        connection.post do |req|
          req.url(strategy.service_endpoint)
          req.headers['Content-Type'] = 'application/json'
          req.body = Oj.dump(results, mode: :compat)
        end
      rescue Faraday::ConnectionFailed
        puts 'There was a problem connecting to Learn. Not pushing test results.'
      end
    end

    def help_option_present?
      options.include?('-h') || options.include?('--help')
    end

    def local_test_run?
      options.include?('-h') || options.include?('--local')
    end

    def die
      puts "This directory doesn't appear to have any specs in it."
      exit
    end
  end
end
