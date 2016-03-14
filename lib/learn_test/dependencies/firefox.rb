require 'selenium-webdriver'

module LearnTest
  module Dependencies
    class Firefox < LearnTest::Dependency
      def missing?
        begin
          Selenium::WebDriver::Firefox::Binary.path

          false
        rescue Selenium::WebDriver::Error::WebDriverError
          true
        end
      end

      def install
        die('Please download and install Firefox: https://www.mozilla.org/en-US/firefox'.red)
      end

      def die(message)
        puts message
        exit
      end
    end
  end
end
