# frozen_string_literal: true

require 'open3'

module LearnTest
  module Strategies
    class Protractor < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_protractor'
      end

      def detect
        runner.files.include?('conf.js')
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
        Dependencies::Protractor.new.execute
      end

      def run
        unless selenium_running?
          stdin, stdout, stderr, wait_thr = Open3.popen3('webdriver-manager start')
          @pid = wait_thr.pid

          @server_started = false

          while !@server_started && line = stderr.gets do
            puts line
            if line.include?('Selenium Server is up and running')
              @server_started = true
              stdin.close
              stdout.close
              stderr.close
            end
          end
        end

        Open3.popen3('protractor conf.js --resultJsonOutputFile .results.json') do |stdin, stdout, stderr, wait_thr|
          while line = stdout.gets do
            if line.include?('Error: Cannot find module')
              @modules_missing = true
            end
            puts line
          end

          while stderr_line = stderr.gets do
            puts stderr_line
          end

          if wait_thr.value.exitstatus != 0
            if @modules_missing
              die("You appear to be missing npm dependencies. Try running `npm install`\nIf the issue persists, check the package.json")
            end
          end
        end

        safe_kill(@pid)
        safe_kill(@selenium_pid) if selenium_running?
      end

      def output
        File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'protractor',
              formatted_output: output,
              duration: duration
            }]
          },
          examples: passing_count + failure_count,
          passing_count: passing_count,
          failure_count: failure_count
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      private

      def passing_count
        @passing_count ||= output.inject(0) do |count, test|
          count += 1 if test[:assertions].all? { |a| a[:passed] }
          count
        end
      end

      def failure_count
        @failure_count ||= output.inject(0) do |count, test|
          count += 1 unless test[:assertions].all? { |a| a[:passed] }
          count
        end
      end

      def duration
        @duration ||= output.inject(0) do |count, test|
          count += test[:duration]
        end
      end

      def safe_kill(pid)
        begin
          Process.kill('HUP', pid)
        rescue
        end
      end

      def selenium_running?
        process = `ps aux | grep selenium`.split("\n").detect { |p| p.include?('chromedriver') }
        if process
          @selenium_pid = process.split[1].to_i
          return true
        end
        false
      end
    end
  end
end
