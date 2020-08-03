# frozen_string_literal: true

module LearnTest
  module Dependencies
    class PhantomJS < LearnTest::Dependency
      def missing?
        if mac?
          die('You must have Homebrew installed') unless brew_installed?
          return !phantom_installed_on_mac?
        end

        unless phantom_installed_on_linux?
          die('You must have PhantomJS installed: http://phantomjs.org/download.html')
        end

        super
      end

      def install
        install_phantomjs
      end

      private

      def brew_installed?
        !`which brew`.empty?
      end

      def phantom_installed_on_mac?
        phantom_installed_by_brew? || phantom_installed?
      end

      def phantom_installed_on_linux?
        phantom_installed?
      end

      def self.check_installation
        new.check_installation
      end

      def check_installation; end

      def phantom_installed_by_brew?
        !`brew ls --versions phantomjs`.empty?
      end

      def phantom_installed?
        !`which phantomjs`.empty?
      end

      def install_phantomjs
        print_installing('phantomjs')
        `brew install phantomjs`
      end
    end
  end
end
