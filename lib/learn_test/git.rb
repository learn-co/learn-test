# frozen_string_literal: true

require 'git'

module LearnTest
  module Git
    def self.open(directory: './', options: {})
      Base.open(directory, options)
    end

    class Base < ::Git::Base
      def wip(message:)
        wip = Wip::Base.new(base: self, message: message)
        wip.process!
        wip
      end
    end
  end
end
