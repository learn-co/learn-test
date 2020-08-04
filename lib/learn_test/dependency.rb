# frozen_string_literal: true

module LearnTest
  class Dependency
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def execute
      install if missing?
    end

    def missing?
      false
    end

    def install; end

    def die(message); end

    def mac?
      !!RUBY_PLATFORM.match(/darwin/)
    end

    def win?
      !!RUBY_PLATFORM.match(/mswin|mingw|cygwin/)
    end

    def print_installing(name)
      puts "Installing missing dependency #{name}...".green
    end

    def run_install(command)
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        while out = stdout.gets do
          puts out
        end

        while err = stderr.gets do
          puts err
        end

        if wait_thr.value.exitstatus != 0
          die("There was an error running #{command}")
        end
      end
    end
  end
end
