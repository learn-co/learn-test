module LearnTest
  module Jasmine
    class Initializer
      def self.run
        new.run
      end

      def run
        make_spec_directory
        generate_app_js
      end

      def make_spec_directory
        FileUtils.mkdir_p('spec')
        FileUtils.touch('spec/.keep')
      end

      def generate_app_js
        FileUtils.cp(
          "#{FileFinder.location_to_dir('templates')}/requires.yml.example",
          'requires.yml'
        )
      end
    end
  end
end

