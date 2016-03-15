module LearnTest
  module Dependencies
    class SeleniumWebdriver < LearnTest::Dependency
      def missing?
        `gem list | grep selenium-webdriver`.empty?
      end

      def install
        print_installing('selenium-webdriver')
        run_install('gem install selenium-webdriver -v 2.52.0')
      end
    end
  end
end
