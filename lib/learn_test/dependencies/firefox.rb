require 'selenium-webdriver'

module LearnTest
  module Dependencies
    class Firefox < LearnTest::Dependency
      def missing?
        begin
          Selenium::WebDriver::Firefox::Binary.path

          false
        rescue Selenium::WebDriver::Error::WebDriverError => e
          true
        end
      end

      def install
        die('Please install Firefox'.red)
      end
    end
  end
end
