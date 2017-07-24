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

    def push_results?
      true
    end

    def cleanup
    end

    def username
      @username ||= LearnTest::UsernameParser.get_username
    end

    def user_id
      @user_id ||= LearnTest::UserIdParser.get_user_id
    end

    def learn_oauth_token
      @learn_oauth_token ||= LearnTest::LearnOauthTokenParser.get_learn_oauth_token
    end

    def argv
      options[:argv]
    end

    def die(message)
      puts message.red
      exit
    end

    ##
    # npm_install option added to fix the proxying of the npm install progress
    # bar output.
    def run_install(command, npm_install: false)
      if npm_install
        system(command)
      else
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          while out = stdout.gets do
            puts out
          end

          while err = stderr.gets do
            puts err
          end

          if wait_thr.value.exitstatus != 0
            die("There was an error running #{command}")
          end
        end
      end
    end

    def js_package
      @package ||= File.exist?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
    end

    def has_js_dependency?(dep)
      [:dependencies, :devDependencies].any? { |key| package_json[key] && package_json[key][dep] }
    end

    def missing_dependencies?
      return true if !File.exist?("node_modules")

      [:dependencies, :devDependencies, :peerDependencies].any? do |d|
        (js_package[d] || {}).any? { |p, v| !File.exist?("node_modules/#{p}") }
      end
    end

    def npm_install
      run_install('npm install', npm_install: true) if missing_dependencies?(js_package)
    end
  end
end
