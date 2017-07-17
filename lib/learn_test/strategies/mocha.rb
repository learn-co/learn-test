require 'webrick'

module LearnTest
  module Strategies
    class Mocha < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_mocha'
      end

      def detect
        package = File.exist?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
        return false if !package

        if package[:scripts] && package[:scripts][:test]
          return true if package[:scripts][:test].include? 'mocha'
        end

        if package[:devDependencies] && package[:devDependencies][:mocha]
          return true if (package[:devDependencies][:mocha].length > 0)
        end

        if package[:dependencies] && package[:dependencies][:mocha]
          return true if (package[:dependencies][:mocha].length > 0)
        end

        return false
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
      end

      def run
        run_mocha
      end

      def cleanup
        FileUtils.rm('.learn.auth.data.json') if File.exist?('.learn.auth.data.json')
      end

      def push_results?
        false
      end

      private

      def run_mocha
        package = Oj.load(File.read('package.json'), symbol_keys: true)

        npm_install(package)

        write_auth_data_to_file

        puts "To run the test suite, navigate to #{testing_address} in your browser."
        puts "Refresh the page to rerun tests. To exit, press CTRL-C in the terminal."

        system open_browser unless in_IDE?

        test_server.start
      end

      def missing_dependencies?(package)
        return true if !File.exist?("node_modules")

        [:dependencies, :devDependencies, :peerDependencies].any? do |d|
          (package[d] || {}).any? { |p, v| !File.exist?("node_modules/#{p}") }
        end
      end

      def npm_install(package)
        run_install('npm install', npm_install: true) if missing_dependencies?(package)
      end

      def open_browser
        link = "http://localhost:8000/"

        if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
          "start #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /darwin/
          "open #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
          "xdg-open #{link}"
        end
      end

      def learn_auth_data
        {
          'username' => username,
          'github_user_id' => user_id,
          'learn_oauth_token' => learn_oauth_token,
          'repo_name' => runner.repo,
          'ruby_platform' => RUBY_PLATFORM,
          'ide_container' => in_IDE?
        }
      end

      def write_auth_data_to_file
        File.open('.learn.auth.data.json', 'w+') do |file|
          File.write(file, Oj.dump(learn_auth_data))
        end
      end

      def in_IDE?
        ENV['IDE_CONTAINER'] == 'true'
      end

      def testing_address
        in_IDE? ? "http://#{ENV['HOST_IP']}:#{ENV['PORT']}/" : "http://localhost:8000/"
      end

      def test_server
        repo_directory = File.expand_path('.')

        no_log = WEBrick::Log.new(File.open(File::NULL, 'w'))

        server = WEBrick::HTTPServer.new({
          Port: in_IDE? ? ENV['PORT'] : 8000,
          DocumentRoot: repo_directory,
          Logger: no_log,
          AccessLog: []
        })

        trap 'INT' do
          server.shutdown

          puts "\nExiting test suite..."

          cleanup

          exit
        end

        server
      end
    end
  end
end
