module LearnTest
  class Runner
    attr_reader :repo, :options, :strategy

    def initialize(repo, options = {})
      @repo = repo
      @options = options
      @strategy = select_strategy

      if !strategy
        puts "This directory doesn't appear to have any specs in it."
        exit
      end
    end

    def run
      strategy.new.run(self)
    end

    private

    def select_strategy
      spec_type = LearnTest::SpecTypeParser.new.spec_type

      strategies = {
        jasmine: LearnTest::Strategies::Jasmine,
        rspec: LearnTest::Strategies::Rspec,
        python_unittest: LearnTest::Strategies::PythonUnittest
      }

      strategies[spec_type.to_sym]
    end
  end
end
