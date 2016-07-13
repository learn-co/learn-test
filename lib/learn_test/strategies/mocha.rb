module LearnTest
  module Strategies
    class Mocha < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_mocha'
      end

      def detect
        package = File.exists?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
        return false if !package

        if package[:scripts] && package[:scripts][:test]
          return true if package[:scripts][:test].include?('mocha')
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

      def output
        @output ||= File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
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

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      private

      def run_mocha
        package = Oj.load(File.read('package.json'), symbol_keys: true)

        npm_install

        command = if (package[:scripts] && package[:scripts][:test] || "").include?(".results.json")
          "npm test"
        else
          install_mocha_multi
          "node_modules/.bin/mocha -R mocha-multi --reporter-options spec=-,json=.results.json"
        end

        system(command)
      end

      def install_mocha_multi
        if !File.exists?('node_modules/mocha-multi')
          run_install('npm install mocha-multi')
        end
      end

      def npm_install
        if !File.exists?('node_modules')
          run_install('npm install')
        end
      end
    end
  end
end
