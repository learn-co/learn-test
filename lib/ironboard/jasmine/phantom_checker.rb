module Ironboard
  module Jasmine
    class PhantomChecker
      def self.check_installation
        new.check_installation
      end

      def check_installation
        if !brew_installed?
          puts "You must have Homebrew installed."
          exit
        else
          if !phantom_installed?
            install_phantomjs
          end
        end
      end

      def brew_installed?
        !`which brew`.empty?
      end

      def phantom_installed?
        !`brew ls --versions phantomjs`.empty?
      end

      def install_phantomjs
        `brew install phantomjs`
      end
    end
  end
end

