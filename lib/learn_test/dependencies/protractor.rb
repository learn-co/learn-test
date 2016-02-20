module LearnTest
  module Dependencies
    class Protractor < LearnTest::Dependency
      def missing?
        `which protractor`.empty?
      end

      def install
        print_installing('protractor')
        run_install('npm install -g protractor')
        puts 'Updating webdriver-manager...'.green
        run_install('webdriver-manager update')
      end

      def run_install(command)
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          while out = stdout.gets do
            puts out
          end

          while err = stderr.gets do
            puts err
          end
        end
      end
    end
  end
end
