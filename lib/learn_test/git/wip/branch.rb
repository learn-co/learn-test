# frozen_string_literal: true

module LearnTest
  module Git
    module Wip
      class Branch
        attr_accessor :parent

        def initialize(base:, name:)
          @base = base
          @name = name
        end

        def last_revision(raise_no_commits: false)
          @last_revision ||= begin
            begin
              @base.revparse(@name)
            rescue ::Git::GitExecuteError => e
              regex = Errors::NoCommitsError::REGEX

              if raise_no_commits
                raise e.message.match(regex) ? Errors::NoCommitsError.new(@name) : e
              end

              raise unless e.message.match(regex)

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
