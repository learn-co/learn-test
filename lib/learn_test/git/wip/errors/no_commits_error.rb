# frozen_string_literal: true

module LearnTest
  module Git
    module Wip
      module Errors
        class NoCommitsError < BaseError
          REGEX = /unknown revision or path not in the working tree/i.freeze

          def initialize(branch)
            super "Branch `#{branch}` doesn't have any commits. Please commit and try again."
          end
        end
      end
    end
  end
end
