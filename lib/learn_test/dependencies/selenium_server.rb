module LearnTest
  module Dependencies
    class SeleniumServer < LearnTest::Dependency
      def missing?
        selenium = `where selenium-server`
        selenium.empty? || selenium.match(/not found/i)
      end

      def install
        brew = `where brew`

        if brew.empty? || brew.match(/not found/i)
          die('Please install Selenium Server Standalone'.red)
        else
          print_installing('Selenium Server Standalone')
          run_install('brew install selenium-server-standalone')
        end
      end
    end
  end
end
