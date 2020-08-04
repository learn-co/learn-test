# frozen_string_literal: true

require 'open3'

module LearnTest
  module Pytest
    class RequirementsChecker
      def self.check_installation
        PythonChecker.check
        PipChecker.check
        PytestChecker.check
      end
    end

    class PythonChecker
      def self.check
        return unless !self.python_installed? || !self.correct_python_version?

        puts 'Please install python 2.7.x or 3.x.x'
        exit
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
        return if self.pip_installed?

        puts 'Please ensure pip is installed'
        exit
      end

      def self.pip_installed?
        !`which pip`.empty?
      end
    end

    class PytestChecker
      def self.check
        return if self.pytest_installed?

        puts 'Please ensure pytest is installed'
        exit
      end

      def self.pytest_installed?
        !`which pytest`.empty?
      end
    end

  end
end
