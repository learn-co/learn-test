require 'yaml'

module LearnTest
  module Strategies
    class GreenOnion < LearnTest::Strategy
      attr_reader :rspec_runner

      def initialize
        @rspec_runner = Strategies::Rspec.new
        super
      end

      def service_endpoint
        '/e/green_onion'
      end

      def detect
        runner.files.include?('.learn') && green_onion_lab?
      end

      def configure
        rspec_runner.configure
      end

      def check_dependencies
        Dependencies::Imagemagick.new.execute
        Dependencies::SeleniumServer.new.execute
      end

      def run
        rspec_runner.run
      end

      def output
        rspec_runner.output
      end

      def results
        rspec_runner.results
      end

      def cleanup
        rspec_runner.cleanup
      end

      private

      def green_onion_lab?
        yaml['tests'] && yaml['tests'].include?('green_onion')
      end

      def yaml
        @yaml ||= YAML.parse(File.read('.learn'))
      end
    end
  end
end
