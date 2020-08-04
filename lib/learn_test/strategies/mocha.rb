# frozen_string_literal: true

module LearnTest
  module Strategies
    class Mocha < LearnTest::Strategy
      include LearnTest::JsStrategy

      def service_endpoint
        '/e/flatiron_mocha'
      end

      def detect
        return false unless js_package

        (has_js_dependency?(:mocha) || in_browser?) ? true : false
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
      end

      def run
        run_mocha
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      def push_results?
        !in_browser?
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
        @output ||= File.exist?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      private

      def run_mocha
        npm_install

        if in_browser?
          exec('npm test')
        else
          run_node_based_mocha
        end
      end

      def run_node_based_mocha
        command = if (js_package[:scripts] && js_package[:scripts][:test] || '').include?('.results.json')
          'npm test'
        else
          install_mocha_multi
          'node_modules/.bin/mocha -R mocha-multi --reporter-options spec=-,json=.results.json'
        end

        system(command)
      end

      def in_IDE?
        ENV['IDE_CONTAINER'] == 'true'
      end

      def in_browser?
        @in_browser ||= has_js_dependency?(:'learn-browser')
      end

      def install_mocha_multi
        return if File.exist?('node_modules/mocha-multi')

        run_install('npm install mocha-multi', npm_install: true)
      end
    end
  end
end
