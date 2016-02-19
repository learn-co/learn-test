module LearnTest
  class Runner
    attr_reader :repo, :options

    def initialize(repo, options = {})
      @repo = repo
      @options = options
      die! if strategies.empty?
    end

    def run
      strategies.each do |strategy|
        strategy.check_dependencies
        strategy.configure
        strategy.run
        if !help_option_present? && strategy.push_results?
          push_results(strategy)
          strategy.cleanup unless keep_results?
        end
      end
    end

    def keep_results?
      @keep_results ||= options[:keep] || !!options.delete('--keep')
    end

    private

    def connection
      @connection ||= Faraday.new(url: SERVICE_URL) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def strategies
      @strategies ||= detect_strategies.map{ |s| s.new(self) }
    end

    def detect_strategies
      spec_type = LearnTest::SpecTypeParser.new.spec_type

      strategies = {
        jasmine: LearnTest::Strategies::Jasmine,
        rspec: LearnTest::Strategies::Rspec,
        python_unittest: LearnTest::Strategies::PythonUnittest
      }

      [strategies[spec_type.to_sym]]
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

    def exit!
      puts "This directory doesn't appear to have any specs in it."
      exit
    end
  end
end
