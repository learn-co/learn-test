module LearnTest
  module PythonUnittest
    class NoseInstaller
      def self.install
        new.install
      end

      def install
        install_nose
        install_nose_json
      end

      def install_nose
        if !nose_installed?
          `easy_install nose`
        end
      end

      def nose_installed?
        !`which nosetests`.empty?
      end

      def install_nose_json
        if !nose_json_installed?
          `pip install nose-json`
        end
      end

      def nose_json_installed?
        !`pip show nose-json`.empty?
      end
    end
  end
end

