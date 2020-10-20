# frozen_string_literal: true

module LearnTest
  module Git
    module Wip
      module Errors
        class NoChangesError < BaseError
          def initialize(branch)
            super "No changes found on `#{branch}`"
          end
        end
      end
    end
  end
end
