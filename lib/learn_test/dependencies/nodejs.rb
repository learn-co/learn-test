# frozen_string_literal: true

module LearnTest
  module Dependencies
    class NodeJS < LearnTest::Dependency
      def missing?
        `which node`.empty?
      end

      def install
        if !mac?
          die('Please install NodeJS: https://nodejs.org/en/download')
        else
          puts('Checking for homebrew...'.green)
          die('You must have Homebrew installed') unless brew_installed?
          puts('Updating brew...'.green)
          print_installing('node')
          run_install('brew install node')
        end
      end

      private

      def brew_installed?
        !`which brew`.empty?
      end

      def die(message)
        puts message
        exit
      end
    end
  end
end
