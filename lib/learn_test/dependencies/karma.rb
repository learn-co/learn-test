# frozen_string_literal: true

module LearnTest
  module Dependencies
    class Karma < LearnTest::Dependency
      def missing?
        `which karma`.empty?
      end

      def install
        print_installing('karma')
        run_install('npm install -g karma-cli')
      end
    end
  end
end
