require 'crack'
require 'json'

module LearnTest
  module Strategies
    class JavaJunit < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_java_junit'
      end

      def detect
        runner.files.any? { |f| f.match(/^javacs\-lab\d+$/) }
      end

      def check_dependencies
        Dependencies::Java.new.execute
        Dependencies::Ant.new.execute
      end

      def run
        run_ant
        make_json
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'junit',
              formatted_output: [],
              duration: 0.0
            }]
          },
          examples: 0,
          passing_count: 0,
          failure_count: 0
        }
      end

      def cleanup
      end

      private

      def run_ant
        system('ant test -buildfile javacs*/build.xml')
        # output is in javacs*/junit/*.xml <-- need to combine those like in jasmine
      end

      def test_path
        @test_path ||= File.expand_path("#{lab_dir}/junit", FileUtils.pwd)
      end

      def lab_dir
        @lab_dir ||= Dir.entries('.').detect {|f| f.match(/^javacs\-lab\d+$/)}
      end

      def make_json

      end

      def test_xml_files
        Dir.entries(test_path).select { |f| f.end_with?('.xml') }
      end
    end
  end
end
