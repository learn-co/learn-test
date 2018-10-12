require 'open3'

module LearnTest
  module Pytest
    class RequirementsChecker
      def self.check_installation
        new.check_installation
      end

      def check_installation
        PythonChecker.check
        PipChecker.check
        PytestChecker.check
      end
    end

    class PythonChecker
      def self.check
        new.check
      end

      def check
        if !python_installed? || !correct_python_version?
          puts "Please install python 2.7.x or 3.x.x"
          exit
        end
      end

      def python_installed?
        !`which python`.empty?
      end

      def correct_python_version?
        output = Open3.popen2e('python', '--version')
        version = output[1].read.strip
        !!version.match(/ 2.7.*| 3.*/)
      end
    end

    class PipChecker
      def self.check
        new.check
      end

      def check
        if !pip_installed?
          puts "Please ensure pip is installed"
          exit
        end
      end

      def pip_installed?
        !`which pip`.empty?
      end
    end

    class PytestChecker
      def self.check
        new.check
      end

      def check
        if !pytest_installed?
          puts "Please ensure pytest is installed"
          exit
        end
      end

      def pytest_installed?
        !`which pytest`.empty?
      end
    end

  end
end
