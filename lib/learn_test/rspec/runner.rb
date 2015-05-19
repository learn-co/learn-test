module LearnTest
  module RSpec
    class Runner
      attr_accessor :parsed_output, :json_output, :formatted_results
      attr_reader :username, :user_id, :repo_name, :options, :connection

      def initialize(username, user_id, repo_name, options)
        @username = username
        @user_id = user_id
        @repo_name = repo_name
        @options = options
        @json_output = ""
        @parsed_output = nil
        @formatted_results = {}
        @connection = Faraday.new(url: SERVICE_URL) do |faraday|
          faraday.adapter  Faraday.default_adapter
        end
      end

      def run
        check_options
        run_rspec
        if !options.include?('-h') && !options.include?('--help')
          set_json_output
          jsonify
          format_results
          push_results
          cleanup
        end
      end

      def check_options
        options_has_format = options.include?('--format') || options.include?('-f')
        if dot_rspec = read_dot_rspec
          if options_has_format
            if dot_rspec.any? {|dot_opt| dot_opt.match(/--format|-f/)}
              options << dot_rspec.reject {|dot_opt| dot_opt.match(/--format|-f/)}
            else
              options << dot_rspec
            end
          end
        end

        if options_has_format
          self.options.flatten!
        else
          options.unshift('--format documentation')
        end

        # Don't pass the test/local flag from learn binary to rspec runner.
        options.delete("--test")
        options.delete("-t")
        options.delete("-l")
        options.delete("--local")
      end

      def read_dot_rspec
        if File.exist?('.rspec')
          File.readlines('.rspec').map(&:strip)
        else
          nil
        end
      end

      def run_rspec
        system("rspec #{options.join(' ')} --format j --out .results.json")
      end

      def set_json_output
        self.json_output = File.read('.results.json')
      end

      def jsonify
        self.parsed_output = Oj.load(json_output, symbol_keys: true)
      end

      def format_results
        self.formatted_results.merge!({
          username: username,
          github_user_id: user_id,
          repo_name: repo_name,
          build: {
            test_suite: [{
              framework: 'rspec',
              formatted_output: parsed_output,
              duration: parsed_output[:summary][:duration]
            }]
          },
          examples: parsed_output[:summary][:example_count],
          passing_count: parsed_output[:summary][:example_count] - parsed_output[:summary][:failure_count] - parsed_output[:summary][:pending_count],
          pending_count: parsed_output[:summary][:pending_count],
          failure_count: parsed_output[:summary][:failure_count],
          failure_descriptions: parsed_output[:examples].select do |example|
            example[:status] == "failed"
          end.map { |ex| ex[:full_description] }.join(";")
        })
      end

      def push_results
        connection.post do |req|
          req.url SERVICE_ENDPOINT
          req.headers['Content-Type'] = 'application/json'
          req.body = Oj.dump(formatted_results, mode: :compat)
        end
      end

      def cleanup
        FileUtils.rm('.results.json')
      end
    end
  end
end

