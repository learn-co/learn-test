# frozen_string_literal: true

require 'fileutils'
require 'json'

require_relative 'client'
require_relative 'git_wip'

module LearnTest
  class Reporter
    attr_accessor :output_path, :debug

    def self.report(strategy, options = {})
      reporter = new(strategy, options)
      reporter.report
      reporter.retry_failed_reports
    end

    def initialize(strategy, options = {})
      @strategy = strategy
      @output_path = options[:output_path] || File.join(Dir.home, '.learn.debug')
      @client = options[:client] || LearnTest::Client.new
      @debug = options[:debug]
    end

    def failed_reports
      return {} unless File.exists?(output_path)
      JSON.load(File.read(output_path)) || {}
    end

    def retry_failed_reports
      previous_reports = failed_reports
      previous_reports.delete_if do |endpoint, results|
        results.delete_if do |result|
          !!client.post_results(endpoint, result)
        end.empty?
      end

      if previous_reports.empty?
        FileUtils.rm_f(output_path)
      else
        File.open(output_path, 'w') do |file|
          file.write("#{JSON.dump(previous_reports)}\n")
        end
      end
    end

    def report
      results = strategy.results
      endpoint = strategy.service_endpoint
      augment_results!(results)

      if client.post_results(endpoint, results)
        if !LearnTest::GitWip.run! && @debug
          puts 'There was a problem connecting to Github. Not pushing current branch state.'.red
        end
      else
        if @debug
          puts 'There was a problem connecting to Learn. Not pushing test results.'.red
        end

        save_failed_attempt(endpoint, results)
      end
    end

    private

    attr_reader :strategy, :client

    def save_failed_attempt(endpoint, results)
      File.open(output_path, File::RDWR | File::CREAT, 0644) do |f|
        if f.flock(File::LOCK_EX)
          begin
            reports = JSON.load(f)
            reports ||= {}
            reports[endpoint] ||= []
            reports[endpoint] << results

            f.rewind
            f.write("#{JSON.dump(reports)}\n")
            f.flush
            f.truncate(f.pos)
          ensure
            f.flock(File::LOCK_UN)
          end
        end
      end
    end

    def augment_results!(results)
      if File.exist?("#{FileUtils.pwd}/.learn")
        dot_learn = YAML.load(File.read("#{FileUtils.pwd}/.learn"))

        unless dot_learn['github'].nil?
          results[:github] = dot_learn['github']
        end
      end

      results[:created_at] = Time.now
      results[:ruby_platform] = RUBY_PLATFORM
      results[:learning_environment] = ENV['LEARNING_ENVIRONMENT']
      results[:ide_container] = (ENV['IDE_CONTAINER'] == 'true')
    end
  end
end
