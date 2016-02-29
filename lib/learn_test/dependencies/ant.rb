module LearnTest
  module Dependencies
    class Ant < LearnTest::Dependency
      def missing?
        `which ant`.empty?
      end

      def install
        puts('Checking for homebrew...'.green)
        die('You must have Homebrew installed') unless brew_installed?
        puts('Updating brew...'.green)
        print_installing('ant')
        run_install('brew install ant')
      end

      private

      def brew_installed?
        !`which brew`.empty?
      end
    end
  end
end
