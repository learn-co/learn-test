module LearnTest
  module PythonUnittest
    class Runner
      attr_accessor :parsed_output, :json_output, :formatted_results
      attr_reader   :username, :user_id, :repo_name, :options, :connection

      def initialize(username, user_id, repo_name, options)
        @username = username
        @user_id = user_id
        @repo_name = repo_name
        @options = options
        @json_output = ""
        @parsed_output = nil
        @formatted_results = {}
        @connection = Faraday.new(url: SERVICE_URL) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
      end

      def run
        run_nose
        if !options.include?('-h') && !options.include?('--help')
          set_json_output
          jsonify
          format_results
          push_results
          cleanup
        end
      end

      def run_nose
        system("nosetests #{options.join(' ')} --verbose --with-json --json-file='./.results.json'")
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
              framework: 'unittest',
              formatted_output: parsed_output,
              duration: calculate_duration
            }]
          },
          examples: parsed_output[:stats][:total],
          passing_count: parsed_output[:stats][:passes],
          pending_count: parsed_output[:stats][:skipped],
          failure_count: parsed_output[:stats][:errors],
          failure_descriptions: concat_failure_descriptions
        })
      end

      def calculate_duration
        parsed_output[:results].map do |example|
          example[:time]
        end.inject(:+)
      end

      def concat_failure_descriptions
        parsed_output[:results].select do |example|
          example[:type] == 'failure'
        end.map { |ex| ex[:tb] }.join(';')
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

