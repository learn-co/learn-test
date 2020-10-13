module LearnTest
  module Git
    module Wip
      class Branch
        attr_accessor :parent

        def initialize(base:, name:)
          @base = base
          @name = name
        end

        def last_revision(raise_no_commits: true)
          @last_revision ||= begin
            begin
              @base.revparse(@name)
            rescue ::Git::GitExecuteError => e
              if raise_no_commits
                raise e.message.match(NoCommitsError::REGEX) ? NoCommitsError : e 
              end

              raise unless e.message.match(NoCommitsError::REGEX)
              false
            end
          end
        end

        def to_s
          @name
        end
      end
    end
  end
end
