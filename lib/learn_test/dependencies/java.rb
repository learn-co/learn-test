# frozen_string_literal: true

module LearnTest
  module Dependencies
    class Java < LearnTest::Dependency
      def missing?
        if win?
          `where java`.empty?
        else
          `which java`.empty?
        end
      end

      def install
        die('Please install Java')
      end

      def die(message)
        puts message
        exit
      end
    end
  end
end
