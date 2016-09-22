require 'yaml'

module LearnTest
  class Runner
    attr_reader :repo, :options
    SERVICE_URL = 'http://ironbroker-v2.flatironschool.com'
    PROFILE_PATH = "#{ENV['HOME']}/.learn_profile"

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
      strategy.cleanup unless keep_results?

      update_profile
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

    def profile_needs_update?
      profile = read_profile
      return true if profile.nil?
      profile['generated_at'].to_i < (Time.now.to_i - 86400)
    end

    def request_profile
      local_connection ||= Faraday.new(url: 'http://localhost:3000') do |faraday|
        faraday.adapter(Faraday.default_adapter)
      end

      response = local_connection.get do |req|
        req.url('/api/metrics.json')
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{strategy.learn_oauth_token}"
      end

      response.body
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
