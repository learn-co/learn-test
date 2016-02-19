module LearnTest
  class Strategy
    attr_reader :runner, :options

    def initialize(runner)
      @runner  = runner
      @options = runner.options
    end

    def service_endpoint
      raise NotImplementedError, 'you must add the service endpoint to the test strategy'
    end

    def check_dependencies
    end

    def configure
    end

    def run
      raise NotImplementedError, 'you must implement how this strategy runs its tests'
    end

    def output
      raise NotImplementedError, 'you must implement how the test gets its raw output'
    end

    def results
      output
    end

    def cleanup
    end

    def username
      @username ||= LearnTest::UsernameParser.get_username
    end

    def user_id
      @user_id ||= LearnTest::UserIdParser.get_user_id
    end
  end
end
