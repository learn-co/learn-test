require_relative 'jasmine/initializer'

module LearnTest
  module Strategies
    class Jasmine < LearnTest::Strategy
      def service_endpoint
        '/e/flatiron_jasmine'
      end

      def detect
        runner.files.include?('requires.yml')
      end

      def check_dependencies
        Dependencies::PhantomJS.new.execute unless options[:skip]
      end

      def run
        require 'crack'
        require 'erb'
        require 'yaml'
        require 'json'

        if options[:init]
          LearnTest::Jasmine::Initializer.run
        else
          set_up_runner
          run_jasmine
          make_json
        end
      end

      def results
        @results ||= {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'jasmine',
              formatted_output: [],
              duration: 0.0
            }]
          },
          tests: 0,
          errors: 0,
          failures: 0
        }
      end

      def push_results?
        !local? && !browser?
      end

      def cleanup
        test_xml_files.each do |file|
          FileUtils.rm(file)
        end

        FileUtils.rm_rf("#{Dir.pwd}/tmpTestSupport") if !browser?
      end

      def username
        options[:skip] ? "jasmine-flatiron" : super
      end

      def user_id
        options[:skip] ? "none" : super
      end

      def learn_oauth_token
        options[:skip] ? nil : super
      end

      private

      def set_up_runner
        template = ERB.new(File.read("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine/templates')}/SpecRunnerTemplate#{color_option}.html.erb"))

        yaml = YAML.load(File.read('requires.yml'))["javascripts"]

        required_files = yaml["files"]
        required_specs = yaml["specs"]

        @javascripts = []
        @javascripts << (required_files && required_files.map {|f| "#{test_path}/#{f}"})
        @javascripts << (required_specs && required_specs.map {|f| "#{test_path}/#{f}"} )
        @javascripts.flatten!.compact!

        copy_support_files

        File.open("#{Dir.pwd}/tmpTestSupport/SpecRunner#{color_option}.html", "w+") do |f|
          f << template.result(binding)
        end
      end

      def copy_support_files
        FileUtils.mkdir("#{Dir.pwd}/tmpTestSupport") if !File.exist?("#{Dir.pwd}/tmpTestSupport")

        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jasmine.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jasmine-html.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/console.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/boot.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jquery-1.8.0.min.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jquery-ui-1.8.23.custom.min.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jasmine-jquery.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jasmine.css","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine')}/jasmine_favicon.png","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine/formatters')}/jasmine2-junit.js","#{Dir.pwd}/tmpTestSupport/")
        FileUtils.cp("#{LearnTest::FileFinder.location_to_dir('strategies/jasmine/helpers')}/ConsoleHelper.js","#{Dir.pwd}/tmpTestSupport/")
      end

      def run_jasmine
        if browser?
          chrome_on_mac_path ="\"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome\""
          chrome_on_linux_path = "google-chrome"
          jasmine_lab_path_for_chrome = "\"#{Dir.pwd}/tmpTestSupport/SpecRunner#{color_option}.html\" --allow-file-access-from-files"

          if RUBY_PLATFORM.include?("linux")
            system("#{chrome_on_linux_path} #{jasmine_lab_path_for_chrome}")
          else
            system("#{chrome_on_mac_path} #{jasmine_lab_path_for_chrome}")
          end
        else
          system("phantomjs #{LearnTest::FileFinder.location_to_dir('strategies/jasmine/runners')}/run-jasmine.js #{Dir.pwd}/tmpTestSupport/SpecRunner#{color_option}.html")
        end
      end

      def test_xml_files
        Dir.entries(test_path).keep_if { |f| f.match(/TEST/) }
      end

      def make_json
        if local? || !browser?
          test_xml_files.each do |f|
            parsed = JSON.parse(Crack::XML.parse(File.read(f)).to_json)["testsuites"]["testsuite"]
            results[:build][:test_suite][0][:formatted_output] << parsed["testcase"]
            results[:build][:test_suite][0][:formatted_output].flatten!
            results[:tests] += parsed["tests"].to_i
            results[:errors] += parsed["errors"].to_i
            results[:failures] += parsed["failures"].to_i
            results[:build][:test_suite][0][:duration] += parsed["time"].to_f
          end
          results[:passing_count] = results[:tests] - results[:failures] - results[:errors]
        end

        if out || runner.keep_results?
          output_file = out ? out : '.results.json'
          write_json_output(output_file: output_file)
        end
      end

      def write_json_output(output_file:)
        File.open(output_file, 'w+') do |f|
          f.write(results.to_json)
        end
      end

      def color_option
        !options[:color] ? '' : 'NoColor'
      end

      def local?
        !!options[:local]
      end

      def browser?
        !!options[:browser]
      end

      def out
        options[:out]
      end

      def test_path
        @test_path ||= FileUtils.pwd
      end
    end
  end
end
