module LearnTest
  module Dependencies
    class Ant < LearnTest::Dependency
      def missing?
        if mingw32?
          `where ant`.empty?
        else
          `which ant`.empty?
        end
      end

      def install
        if mingw32?
          die('Please install Ant.')
        else
          puts('Checking for homebrew...'.green)
          die('You must have Homebrew installed') unless brew_installed?
          puts('Updating brew...'.green)
          print_installing('ant')
          run_install('brew install ant')
        end
      end

      private

      def brew_installed?
        !`which brew`.empty?
      end
    end
  end
end
