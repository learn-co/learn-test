# frozen_string_literal: true

module LearnTest
  module Dependencies
    class SeleniumServer < LearnTest::Dependency
      def missing?
        if win?
          selenium = `where selenium-server`
        else
          selenium = `which selenium-server`
        end

        selenium.empty? || selenium.match(/not found/i)
      end

      def install
        if win?
          brew = false
        else
          brew = `which brew`
        end

        if brew.empty? || brew.match(/not found/i)
          die('Please install Selenium Server Standalone'.red)
        else
          print_installing('Selenium Server Standalone')
          run_install('brew install selenium-server-standalone')
        end
      end

      def die(message)
        puts message
        exit
      end
    end
  end
end
