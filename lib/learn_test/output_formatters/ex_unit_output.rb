module LearnTest
  class NullExUnitOutput
    attr_reader :duration, :example_count, :failure_count, :pending_count, :passing_count, :raw, :failures
    def initialize
      @duration = nil
      @example_count = 1
      @passing_count = 0
      @pending_count = 0
      @failure_count = 1
      @raw = nil
      @failures = 'A syntax error prevented RSpec from running.'
    end
  end

  class ExUnitOutput
    attr_reader :duration, :example_count, :failure_count, :pending_count, :passing_count, :raw, :failures
    def self.new(raw_output)
      if raw_output
        super
      else
        NullExUnitOutput.new
      end
    end

    def initialize(raw_output)
      @duration = raw_output[:summary][:duration]

      @example_count = raw_output[:summary][:example_count]
      @failure_count = raw_output[:summary][:failure_count]
      @pending_count = raw_output[:summary][:pending_count]
      @passing_count = example_count - failure_count - pending_count
      @raw = raw_output
    end

    def failures
      raw[:examples].select do |example|
        example[:status] == "failed"
      end.map { |ex| ex[:full_description] }.join(";")
    end
  end
end
