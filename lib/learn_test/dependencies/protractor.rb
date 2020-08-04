# frozen_string_literal: true

module LearnTest
  module Dependencies
    class Protractor < LearnTest::Dependency
      def missing?
        `which protractor`.empty?
      end

      def install
        print_installing('protractor')
        run_install('npm install -g protractor')
        puts 'Updating webdriver-manager...'.green
        run_install('webdriver-manager update')
      end
    end
  end
end
