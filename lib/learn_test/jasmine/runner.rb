require 'crack'
require 'erb'
require 'yaml'
require 'json'

module LearnTest
  module Jasmine
    class Runner
      attr_reader :no_color, :local, :browser, :conn, :color_opt, :out, :keep_results
      attr_accessor :json_results

      def self.run(repo, options)
        if options[:init]
          LearnTest::Jasmine::Initializer.run
        else
          if !options[:skip]
            LearnTest::Jasmine::PhantomChecker.check_installation
            username = LearnTest::UsernameParser.get_username
            user_id = LearnTest::UserIdParser.get_user_id
          else
            username = "jasmine-flatiron"
            user_id = "none"
          end
          new(username, user_id, repo, options).run
        end
      end

      def initialize(username, user_id, repo_name, options)
        @current_test_path = FileUtils.pwd
        @no_color = !!options[:color]
        @color_opt = !no_color ? "" : "NoColor"
        @local = !!options[:local]
        @browser = !!options[:browser]
        @out = options[:out]
        @keep_results = options[:keep]
        @json_results = {
          username: username,
          github_user_id:user_id,
          repo_name: repo_name,
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
        @conn = Faraday.new(url: SERVICE_URL) do |faraday|
          faraday.adapter  Faraday.default_adapter
        end
      end

      def run
        make_runner_html
        run_jasmine
        make_json
        push_to_flatiron unless local || browser
        clean_up
      end

      def run_jasmine
        if browser
          # system("open #{LearnTest::FileFinder.location_to_dir('jasmine/runners')}/SpecRunner#{color_opt}.html --args allow-file-access-from-files")
          chrome_with_file_access_command = "\"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome\" \"#{LearnTest::FileFinder.location_to_dir('jasmine/runners')}/SpecRunner#{color_opt}.html\" --allow-file-access-from-files"
          # This should give me back to the prompt - u can use & but a flag to send it to the background would be better.
          system(chrome_with_file_access_command)
        else
          system("phantomjs #{LearnTest::FileFinder.location_to_dir('jasmine/runners')}/run-jasmine.js #{LearnTest::FileFinder.location_to_dir('jasmine/runners')}/SpecRunner#{color_opt}.html")
        end
      end

      def make_json
        if local || !browser
          test_xml_files.each do |f|
            parsed = JSON.parse(Crack::XML.parse(File.read(f)).to_json)["testsuites"]["testsuite"]
            json_results[:build][:test_suite][0][:formatted_output] << parsed["testcase"]
            json_results[:build][:test_suite][0][:formatted_output].flatten!
            json_results[:tests] += parsed["tests"].to_i
            json_results[:errors] += parsed["errors"].to_i
            json_results[:failures] += parsed["failures"].to_i
            json_results[:build][:test_suite][0][:duration] += parsed["time"].to_f
          end
          set_passing_test_count
        end

        if out || keep_results
          output_file = out ? out : '.results.json'
          write_json_output(output_file: output_file)
        end
      end

      def set_passing_test_count
        json_results[:passing_count] = json_results[:tests] - json_results[:failures] - json_results[:errors]
      end

      def write_json_output(output_file:)
        File.open(output_file, 'w+') do |f|
          f.write(json_results.to_json)
        end
      end

      def push_to_flatiron
        conn.post do |req|
          req.url SERVICE_ENDPOINT
          req.headers['Content-Type'] = 'application/json'
          req.body = json_results.to_json
        end
      end

      def make_runner_html
        template = ERB.new(File.read("#{LearnTest::FileFinder.location_to_dir('jasmine/templates')}/SpecRunnerTemplate#{color_opt}.html.erb"))

        yaml = YAML.load(File.read('requires.yml'))["javascripts"]

        required_files = yaml["files"]
        required_specs = yaml["specs"]

        @javascripts = []
        @javascripts << (required_files && required_files.map {|f| "#{@current_test_path}/#{f}"})
        @javascripts << (required_specs && required_specs.map {|f| "#{@current_test_path}/#{f}"} )
        @javascripts.flatten!.compact!

        File.open("#{LearnTest::FileFinder.location_to_dir('jasmine/runners')}/SpecRunner#{color_opt}.html", 'w+') do |f|
          f << template.result(binding)
        end
      end

      def test_xml_files
        Dir.entries(@current_test_path).keep_if { |f| f.match(/TEST/) }
      end

      def clean_up
        test_xml_files.each do |file|
          FileUtils.rm(file)
        end
      end
    end
  end
end
