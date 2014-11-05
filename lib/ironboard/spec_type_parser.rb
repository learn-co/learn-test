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
      elsif files.include?('spec')
        spec_files = Dir.entries('./spec')
        if spec_files.include?('spec_helper.rb') || spec_files.include?('rails_helper.rb')
          "rspec"
        end
      end
    end
  end
end
