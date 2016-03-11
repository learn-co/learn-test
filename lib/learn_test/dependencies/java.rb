module LearnTest
  module Dependencies
    class Java < LearnTest::Dependency
      def missing?
        if mingw32?
          `where java`.empty?
        else
          `which java`.empty?
        end
      end

      def install
        die('Please install Java')
      end
    end
  end
end
