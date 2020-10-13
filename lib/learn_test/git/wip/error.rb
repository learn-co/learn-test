module LearnTest
  module Git
    module Wip
      class Error < StandardError; end

      class NoChangesError < Error
        def initialize(branch)
          super 'No changes found'
        end
      end

      class NoCommitsError < Error
        REGEX = /unknown revision or path not in the working tree/.freeze

        def initialize(branch)
          super "Branch `#{branch}` doesn't have any commits"
        end
      end
    end
  end
end
