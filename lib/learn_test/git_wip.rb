# frozen_string_literal: true

require 'git'

module LearnTest
  module GitWip
    class << self
      def run!(log: false)
        git = Git.open('./', log: log)
        working_branch = git.current_branch

        `learn-test-wip save "Automatic test submission" -u &> /dev/null`

        return false unless $?.success? # rubocop:disable Style/SpecialGlobalVars

        git.push('origin', "wip/#{working_branch}:refs/heads/wip")
        git.config['remote.origin.url'].gsub('.git', '/tree/wip')
      rescue StandardError
        false
      end
    end
  end
end
