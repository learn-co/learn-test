module LearnTest
  module Dependencies
    class NodeJS < LearnTest::Dependency
      def missing?
        `which node`.empty?
      end

      def install
        puts('Checking for homebrew...'.green)
        die('You must have Homebrew installed') unless brew_installed?
        puts('Updating brew...'.green)
        print_installing('node')
        run_install('brew install node')
      end

      private

      def brew_installed?
        !`which brew`.empty?
      end
    end
  end
end
