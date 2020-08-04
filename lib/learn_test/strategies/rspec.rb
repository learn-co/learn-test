# frozen_string_literal: true

module LearnTest
  module Strategies
    class Rspec < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_rspec'
      end

      def detect
        runner.files.include?('spec') && (spec_files.include?('spec_helper.rb') || spec_files.include?('rails_helper.rb'))
      end

      def configure
        if format_option_present?
          if dot_rspec.any? { |dot_opt| dot_opt.match(/--format|-f/) }
            argv << dot_rspec.reject { |dot_opt| dot_opt.match(/--format|-f/) }
          else
            argv << dot_rspec
          end
          argv.flatten!
        else
          argv.unshift('--format documentation')
        end

        if fail_fast_option_present?
          argv << '--fail-fast'
        end

        if example_option_present?
          argv << options[:example].map { |e| "--example #{e}" }.join(' ')
        end

        # Don't pass the test/local flag from learn binary to rspec runner.
        argv.delete('--test')
        argv.delete('-t')
        argv.delete('-l')
        argv.delete('--local')
      end

      def run
        system("#{bundle_command}rspec #{argv.join(' ')} --format j --out .results.json")
      end

      def output
        File.exists?('.results.json') ? Oj.load(File.read('.results.json'), symbol_keys: true) : nil
      end

      def results
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'rspec',
              formatted_output: output,
              duration: output ? output[:summary][:duration] : nil
            }]
          },
          examples: output ? output[:summary][:example_count] : 1,
          passing_count: output ? output[:summary][:example_count] - output[:summary][:failure_count] - output[:summary][:pending_count] : 0,
          pending_count: output ? output[:summary][:pending_count] : 0,
          failure_count: output ? output[:summary][:failure_count] : 1,
          failure_descriptions: failures
        }
      end

      def cleanup
        FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      private

      def bundle_command
        File.exist?('Gemfile') && !!File.read('Gemfile').match(/^\s*gem\s*('|")rspec(-[^'"]+)?('|").*$/) ? 'bundle exec ' : ''
      end

      def spec_files
        @spec_files ||= Dir.entries('./spec')
      end

      def format_option_present?
        options[:format]
      end

      def fail_fast_option_present?
        options[:fail_fast]
      end

      def example_option_present?
        options[:example]
      end

      def dot_rspec
        @dot_rspec ||= File.readlines('.rspec').map(&:strip) if File.exist?('.rspec')
      end

      def failures
        if output
          output[:examples].select do |example|
            example[:status] == 'failed'
          end.map { |ex| ex[:full_description] }.join(';')
        else
          'A syntax error prevented RSpec from running.'
        end
      end
    end
  end
end
