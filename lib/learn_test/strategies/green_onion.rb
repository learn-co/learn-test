module LearnTest
  module Strategies
    class GreenOnion < LearnTest::Strategy
      attr_reader :rspec_runner

      def initialize(runner)
        @rspec_runner = Strategies::Rspec.new(runner)
        super
      end

      def service_endpoint
        '/e/flatiron_rspec'
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
        Dependencies::GreenOnion.new.execute
        Dependencies::Firefox.new.execute
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
        @yaml ||= YAML.load(File.read('.learn'))
      end
    end
  end
end
