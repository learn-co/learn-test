# frozen_string_literal: true

require 'yaml'

module LearnTest
  class Runner
    attr_reader :repo, :options

    def initialize(repo, options = {})
      @repo = repo
      @options = options
    end

    def run
      strategy.check_dependencies
      strategy.configure
      strategy.run
      if options[:debug] || options[:sync]
        report_and_clean
      else
        Process.detach(Process.fork do
          report_and_clean
        end)
      end
    end

    def files
      @files ||= Dir.entries('.')
    end

    def keep_results?
      @keep_results ||= options[:keep] || !!options.delete('--keep')
    end

    def strategy
      return @strategy if @strategy

      detected = strategies.map { |s| s.new(self) }.detect(&:detect)

      @strategy = detected || LearnTest::Strategies::None.new(self)
    end

    private

    def report_and_clean
      require_relative 'reporter'

      if !help_option_present? && strategy.push_results? && !local_test_run?
        LearnTest::Reporter.report(strategy, options)
      end

      strategy.cleanup unless keep_results?
    end

    def strategies
      [
        LearnTest::Strategies::CSharpNunit,
        LearnTest::Strategies::Rspec,
        LearnTest::Strategies::Karma,
        LearnTest::Strategies::Protractor,
        LearnTest::Strategies::JavaJunit,
        LearnTest::Strategies::Mocha,
        LearnTest::Strategies::Pytest
      ]
    end

    def help_option_present?
      options.include?('-h') || options.include?('--help')
    end

    def local_test_run?
      options.include?('-h') || options.include?('--local')
    end
  end
end
