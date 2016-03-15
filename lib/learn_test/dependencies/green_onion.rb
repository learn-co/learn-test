module LearnTest
  module Dependencies
    class GreenOnion < LearnTest::Dependency
      def missing?
        `gem list | grep green_onion`.empty?
      end

      def install
        print_installing('green_onion')
        run_install('gem install green_onion -v 0.1.4')
      end
    end
  end
end
