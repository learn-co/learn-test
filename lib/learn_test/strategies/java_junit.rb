# frozen_string_literal: true

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
        require 'crack'
        require 'json'

        clean_old_results
        run_ant
        make_json
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
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
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      private

      def clean_old_results
        return unless Dir.entries(lab_dir).any? { |f| f == 'junit' }
        system("rm -rf #{lab_dir}/junit")
      end

      def run_ant
        javacs_dir = Dir.entries('.').detect { |f| !!f.match(/javacs/) }

        system("ant clean -buildfile #{javacs_dir}/build.xml && ant build -buildfile #{javacs_dir}/build.xml && ant test -buildfile #{javacs_dir}/build.xml")
      end

      def test_path
        @test_path ||= File.expand_path("#{lab_dir}/junit", FileUtils.pwd)
      end

      def lab_dir
        @lab_dir ||= Dir.entries('.').detect { |f| f.match(/^javacs\-lab\d+$/) }
      end

      def make_json
        if File.exists?(test_path)
          test_xml_files.each do |f|
            parsed = JSON.parse(Crack::XML.parse(File.read(f)).to_json)['testsuite']
            next unless parsed

            if parsed['testcase']
              parsed['testcase'].each do |test_case|
                results[:build][:test_suite][0][:formatted_output] << test_case
              end
            end

            test_count    = parsed['tests'].to_i
            skipped_count = parsed['skipped'].to_i
            error_count   = parsed['errors'].to_i
            failure_count = parsed['failures'].to_i
            duration      = parsed['time'].to_f

            results[:examples] += test_count
            results[:passing_count] += (test_count - skipped_count - error_count - failure_count)
            results[:failure_count] += (error_count + failure_count)
            results[:build][:test_suite][0][:duration] = duration
          end
        else
          results[:examples]      = 1
          results[:failure_count] = 1
          results[:passing_count] = 0
        end

        return unless runner.keep_results?

        output_file = '.results.json'
        write_json_output(output_file: output_file)
      end

      def write_json_output(output_file:)
        File.open(output_file, 'w+') do |f|
          f.write(results.to_json)
        end
      end

      def test_xml_files
        Dir.entries(test_path).select { |f| f.match(/^TEST\-.+\.xml$/) }.map { |f| "#{test_path}/#{f}" }
      end
    end
  end
end
