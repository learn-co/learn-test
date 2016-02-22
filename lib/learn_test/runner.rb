module LearnTest
  class Runner
    attr_reader :repo, :options
    SERVICE_URL = 'http://ironbroker07.fe.flatironschool.com'

    def initialize(repo, options = {})
      @repo = repo
      @options = options
      die if !strategy
    end

    def run
      strategy.check_dependencies
      strategy.configure
      strategy.run
      if !help_option_present? && strategy.push_results?
        push_results(strategy)
        strategy.cleanup unless keep_results?
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

    def connection
      @connection ||= Faraday.new(url: SERVICE_URL) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def strategies
      [
        LearnTest::Strategies::Rspec,
        LearnTest::Strategies::Jasmine,
        LearnTest::Strategies::Protractor,
        LearnTest::Strategies::PythonUnittest
      ]
    end

    def push_results(strategy)
      begin
        connection.post do |req|
          req.url(strategy.service_endpoint)
          req.headers['Content-Type'] = 'application/json'
          req.body = Oj.dump(strategy.results, mode: :compat)
        end
      rescue Faraday::ConnectionFailed
        puts 'There was a problem connecting to Learn. Not pushing test results.'
      end
    end

    def help_option_present?
      options.include?('-h') || options.include?('--help')
    end

    def die
      puts "This directory doesn't appear to have any specs in it."
      exit
    end
  end
end
