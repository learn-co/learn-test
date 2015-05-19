module LearnTest
  module Jasmine
    class PhantomChecker
      def self.check_installation
        new.check_installation
      end

      def check_installation
        if running_on_mac?
          if !brew_installed?
            puts "You must have Homebrew installed."
            exit
          else
            if !phantom_installed_on_mac?
              install_phantomjs
            end
          end
        else
          if !phantom_installed_on_linux?
            puts "You must have PhantomJS installed: http://phantomjs.org/download.html"
          end
        end
      end

      def brew_installed?
        !`which brew`.empty?
      end

      def phantom_installed_on_mac?
        phantom_installed_by_brew? || phantom_installed?
      end

      def phantom_installed_on_linux?
        phantom_installed?
      end

      def phantom_installed_by_brew?
        !`brew ls --versions phantomjs`.empty?
      end

      def phantom_installed?
        !`which phantomjs`.empty?
      end

      def install_phantomjs
        `brew install phantomjs`
      end

      def running_on_mac?
        !!RUBY_PLATFORM.match(/darwin/)
      end
    end
  end
end

