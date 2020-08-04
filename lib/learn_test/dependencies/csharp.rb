# frozen_string_literal: true

module LearnTest
  module Dependencies
    class CSharp < LearnTest::Dependency
      def missing?
        if win?
          `where dotnet`.empty?
        else
          `which dotnet`.empty?
        end
      end

      def install
        die('Please install the .NET core from https://www.microsoft.com/net/core')
      end

      def die(message)
        puts message
        exit
      end
    end
  end
end
