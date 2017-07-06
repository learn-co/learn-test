module LearnTest
  module Strategies
    class Jest < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_jest'
      end

      def detect
        package = File.exists?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
        return false if !package

        if package[:scripts] && package[:scripts][:test]
          return true if package[:scripts][:test].include?('jest')
        end

        if package[:devDependencies] && package[:devDependencies][:jest]
          return true if (package[:devDependencies][:jest].length > 0)
        end

        if package[:dependencies] && package[:dependencies][:jest]
          return true if (package[:dependencies][:jest].length > 0)
        end

        return false
      end

      def check_dependencies
        Dependencies::NodeJS.new.execute
      end

      def run
        run_jest
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
              framework: 'jest',
              formatted_output: output,
              duration: duration
            }]
          },
          examples: output[:numTotalTests],
          passing_count: output[:numPassedTests],
          failure_count: output[:numFailedTests]
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      def missing_dependencies?(package)
        return true if !File.exists?("node_modules")

        [:dependencies, :devDependencies, :peerDependencies].any? do |d|
          (package[d] || {}).any? { |p, v| !File.exists?("node_modules/#{p}") }
        end
      end

      private

      def run_jest
        package = Oj.load(File.read('package.json'), symbol_keys: true)

        npm_install(package)

        command = 'npm test'

        system(command)
      end

      def npm_install(package)
        run_install('npm install', npm_install: true) if missing_dependencies?(package)
      end

      def duration
        output[:testResults][0][:endTime] - output[:testResults][0][:startTime]
      end
    end
  end
end
