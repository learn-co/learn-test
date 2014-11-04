require 'crack'
require 'erb'
require 'yaml'
require 'json'

module Ironboard
  module Jasmine
    class Runner
      attr_reader :no_color, :local, :browser, :conn, :color_opt, :out
      attr_accessor :json_results

      def self.run(username, user_id, repo_name, options)
        new(username, user_id, repo_name, options).run
      end

      def initialize(username, user_id, repo_name, options)
        @no_color = !!options[:color]
        @color_opt = !no_color ? "" : "NoColor"
        @local = !!options[:local]
        @browser = !!options[:browser]
        @out = options[:out]
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
          system("open #{Ironboard::FileFinder.location_to_dir('runners')}/SpecRunner#{color_opt}.html")
        else
          system("phantomjs #{Ironboard::FileFinder.location_to_dir('runners')}/run-jasmine.js #{Ironboard::FileFinder.location_to_dir('runners')}/SpecRunner#{color_opt}.html")
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

        if out
          write_json_output
        end
      end

      def set_passing_test_count
        json_results[:passing_count] = json_results[:tests] - json_results[:failures] - json_results[:errors]
      end

      def write_json_output
        File.open(out, 'w+') do |f|
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
        template = ERB.new(File.read("#{Ironboard::FileFinder.location_to_dir('templates')}/SpecRunnerTemplate#{color_opt}.html.erb"))

        yaml = YAML.load(File.read('requires.yml'))["javascripts"]
        required_files = yaml["files"]
        required_specs = yaml["specs"]

        @javascripts = required_files.map {|f| "#{FileUtils.pwd}/#{f}"}.concat(
          required_specs.map {|s| "#{FileUtils.pwd}/#{s}"}
        )

        File.open("#{Ironboard::FileFinder.location_to_dir('runners')}/SpecRunner#{color_opt}.html", 'w+') do |f|
          f << template.result(binding)
        end
      end

      def test_xml_files
        Dir.entries(FileUtils.pwd).keep_if { |f| f.match(/TEST/) }
      end

      def clean_up
        test_xml_files.each do |file|
          FileUtils.rm(file)
        end
      end
    end
  end
end

