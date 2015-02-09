require 'open3'

module Ironboard
  module PythonUnittest
    class RequirementsChecker
      def self.check_installation
        new.check_installation
      end

      def check_installation
        PythonChecker.check
        PipChecker.check
      end
    end

    class PythonChecker
      def self.check
        new.check
      end

      def check
        if !python_installed? || !correct_python_version?
          puts "Please install python 2.7.x"
          exit
        end
      end

      def python_installed?
        !`which python`.empty?
      end

      def correct_python_version?
        output = Open3.popen3('python', '--version')
        version = output[2].read.strip
        !!version.match(/2.7.*/)
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
  end
end

