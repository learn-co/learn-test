module LearnTest
  module Strategies
    class Mocha < LearnTest::Strategy
      attr_accessor :mocha_in_browser

      def service_endpoint
        '/e/flatiron_mocha'
      end

      def detect
        package = File.exist?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
        return false if !package

        if package[:scripts] && package[:scripts][:test] && package[:scripts][:test].include?('mocha')
          self.mocha_in_browser = false

          return true
        end

        if package[:devDependencies]
          if package[:devDependencies][:mocha]
            self.mocha_in_browser = false

            return true
          elsif package[:devDependencies][:'learn-browser']
            self.mocha_in_browser = true

            return true
          end
        end

        if package[:dependencies]
          if package[:dependencies][:mocha]
            self.mocha_in_browser = false

            return true
          elsif package[:dependencies][:'learn-browser']
            self.mocha_in_browser = true

            return true
          end
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
        if mocha_in_browser
          FileUtils.rm('learn.auth.data.json') if File.exist?('learn.auth.data.json')
        else
          FileUtils.rm('.results.json') if File.exist?('.results.json')
        end
      end

      def push_results?
        !mocha_in_browser
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'mocha',
              formatted_output: output,
              duration: output[:stats]
            }]
          },
          examples: output[:stats][:tests],
          passing_count: output[:stats][:passes],
          failure_count: output[:stats][:failures]
        }
      end

      def output
        @output ||= File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      private

      def run_mocha
        package = Oj.load(File.read('package.json'), symbol_keys: true)

        npm_install(package)

        if mocha_in_browser
          run_browser_based_mocha
        else
          run_node_based_mocha(package)
        end
      end

      def run_browser_based_mocha
        write_auth_data_to_file

        puts "Navigate to ".red + testing_address.blue + " in your browser to run the test suite.".red
        puts "As you write code in index.js, save your work often. With each save, the browser"
        puts "will automatically refresh and rerun the test suite against your updated code."
        puts "To exit the test suite and return to your terminal, press CTRL-C.".red

        begin
          command = if browser_sync_executable?
            "browser-sync start --config node_modules/learn-browser/bs-config.js"
          else
            "node_modules/browser-sync/bin/browser-sync.js start --config node_modules/learn-browser/bs-config.js"
          end

          system(command)
        rescue Interrupt
          puts "\nExiting test suite...".red

          cleanup

          exit
        end
      end

      def run_node_based_mocha(package)
        command = if (package[:scripts] && package[:scripts][:test] || "").include?(".results.json")
          "npm test"
        else
          install_mocha_multi
          "node_modules/.bin/mocha -R mocha-multi --reporter-options spec=-,json=.results.json"
        end

        system(command)
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
        File.open('learn.auth.data.json', 'w+') do |file|
          File.write(file, Oj.dump(learn_auth_data))
        end
      end

      def in_IDE?
        ENV['IDE_CONTAINER'] == 'true'
      end

      def browser_sync_executable?
        system("which browser-sync > /dev/null 2>&1")
      end

      def testing_address
        in_IDE? ? "http://#{ENV['HOST_IP']}:#{ENV['PORT']}/" : "http://localhost:8000/"
      end

      def install_mocha_multi
        if !File.exists?('node_modules/mocha-multi')
          run_install('npm install mocha-multi', npm_install: true)
        end
      end
    end
  end
end
