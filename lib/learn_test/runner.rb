module LearnTest
  class Runner
    attr_reader :repo, :options, :strategy, :connection

    def initialize(repo, options = {})
      @repo = repo
      @options = options
      @strategy = select_strategy.new(self)

      if !strategy
        puts "This directory doesn't appear to have any specs in it."
        exit
      end
    end

    def connection
      @connection ||= Faraday.new(url: SERVICE_URL) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def run
      strategy.check_dependencies
      strategy.configure
      strategy.run
      if !help_option_present?
        push_results(strategy.results)
        strategy.cleanup unless keep_results?
      end
    end

    def push_results(results)
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

    private

    def select_strategy
      spec_type = LearnTest::SpecTypeParser.new.spec_type

      strategies = {
        jasmine: LearnTest::Strategies::Jasmine,
        rspec: LearnTest::Strategies::Rspec,
        python_unittest: LearnTest::Strategies::PythonUnittest
      }

      strategies[spec_type.to_sym]
    end

    def keep_results?
      @keep_results ||= !!options.delete('--keep')
    end

    def help_option_present?
      options.include?('-h') || options.include?('--help')
    end
  end
end
