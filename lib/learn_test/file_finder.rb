# frozen_string_literal: true

module LearnTest
  class FileFinder
    def self.location_to_dir(dir_name)
      new.location_to_dir(dir_name)
    end

    def location_to_dir(dir_name)
      File.join(File.dirname(File.expand_path(__FILE__)), "#{dir_name}")
    end
  end
end
