module Ironboard
  class SpecTypeParser
    attr_reader :spec_type

    def initialize
      @spec_type = parse_spec_type
    end

    private

    def parse_spec_type
      files = Dir.entries('.')

      if files.include?('requires.yml')
        "jasmine"
      elsif files.include?('spec') && Dir.entries('./spec').include?('spec_helper.rb')
        "rspec"
      end
    end
  end
end
