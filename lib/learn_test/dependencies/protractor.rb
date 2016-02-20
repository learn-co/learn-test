module LearnTest
  module Dependencies
    class Protractor < LearnTest::Dependency
      def missing?
        `which protractor`.empty?
      end

      def install
        print_installing('protractor')
        `npm install -g protractor`
        puts 'Updating webdriver-manager...'
        `webdriver-manager update`
      end
    end
  end
end
