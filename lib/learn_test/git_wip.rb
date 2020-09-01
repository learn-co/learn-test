# frozen_string_literal: true

require 'git'
require 'logger'

module LearnTest
  module GitWip
    class << self
      def run!(log: false)
        git = Git.open('./', log: log)
        working_branch = git.current_branch

        commands = [
          'learn-test-wip save "Automatic test submission" --editor',
          "git push origin wip/#{working_branch}:refs/heads/wip"
        ].join(';')

        Open3.popen3(commands) do |_stdin, _stdout, _stderr, wait_thr|
          # while out = stdout.gets do; puts out; end
          # while err = stderr.gets do; puts err; end
  
          if wait_thr.value.exitstatus.zero?
            git.config['remote.origin.url'].gsub('.git', '/tree/wip')
          else
            #  puts 'There was an error running learn-test-wip'
            false
          end
        end
      rescue StandardError => e
        false
      end
    end
  end
end
