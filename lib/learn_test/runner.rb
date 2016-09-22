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

      update_profile
      write_test_data_to_profile
      ask_a_question(results)
    end

    def write_test_data_to_profile
      # incrementing test runs
      # incrementing time taken
    end

    def ask_a_question(results)
      if ask_a_question_triggered?(results)
        response = ''
        until response == 'y' || response == 'n'
          puts "Would you like to ask a question? y/n"
          response = STDIN.gets.chomp.downcase
        end

        if response == 'y'
          `open http://localhost:3000/lessons/current?question_id=new`
        else
          'Ok, happy learning!'
        end
        # log the response to learn history and send the response to Learn
        log_response
        sync_response_to_learn(response)
      end
    end

    def sync_response_to_learn(response)
      #send request to endpoint, create struggleprompted
      #prompted_at, user response, threshold, lab, user
    end

    def log_response
      f = File.open(history_path, 'a')
      f.write("aaq"+"\n")
      f.close
    end

    def ask_a_question_triggered?(results)
      profile = read_profile
      return false if profile.nil?

      history = read_history
      return false if history.index('aaq')
      return false if results[:failure_count] == 0

      # check if detection is on for this lab, if it's in the returned lesson_ids hash]
      # look up the lab by its remote repo name 
      # threshold = profile["program"]["lessons"][repo]["event_triggers"]
      # user_metric = profile["program"]["lessons"]["progress"]["test_runs_stuff"]
      # test runs, calculate what percentile someone's in for test runs or time taken
      # if test_runs_percentile exceeds 1 std of mean 
      # read profile and see if tests aren't passing && minimum detection threshold passed
      true
    end

    def update_profile
      if profile_needs_update?
        profile = request_profile
        write_profile(profile)
      end
    end

    def read_profile
      return nil unless File.exists?(profile_path)

      JSON.parse(File.read(profile_path))
    end

    def read_history
      return "" unless File.exists?(history_path)

      File.read(history_path)
    end

    def profile_needs_update?
      profile = read_profile
      return true if profile.nil?
      profile['generated_at'].to_i < (Time.now.to_i - 86400)
    end

    def request_profile
      local_connection ||= Faraday.new(url: 'http://localhost:3000') do |faraday|
        faraday.adapter(Faraday.default_adapter)
      end

      begin
        response = local_connection.get do |req|
          req.url('/api/metrics.json')
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = "Bearer #{strategy.learn_oauth_token}"
        end

        response.body
      rescue Faraday::ConnectionFailed
        'Error: connection failed'
      end
    end

    def write_profile(profile)
      f = File.open(profile_path, 'w+')
      f.write(profile)
      f.close
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
