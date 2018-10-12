# No longer being imported. Removed as curriculum switched entirely to Pytest and test file naming convention may intersect with pytest test file naming convention

require 'open3'

module LearnTest
  module PythonUnittest
    
    class RequirementsChecker
      def self.check_installation
        PythonChecker.check
        PipChecker.check
      end
    end

    class PythonChecker
      def self.check
        if !self.python_installed? || !self.correct_python_version?
          puts "Please install python 2.7.x or 3.x.x"
          exit
        end
      end

      def self.python_installed?
        !`which python`.empty?
      end

      def self.correct_python_version?
        output = Open3.popen2e('python', '--version')
        version = output[1].read.strip
        !!version.match(/ 2.7.*| 3.*/)
      end
    end

    class PipChecker
      def self.check
        if !self.pip_installed?
          puts "Please ensure pip is installed"
          exit
        end
      end

      def self.pip_installed?
        !`which pip`.empty?
      end
    end
  end
end
