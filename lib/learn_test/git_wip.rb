# frozen_string_literal: true

require 'git'

module LearnTest
  module GitWip
    class << self
      def run!(log: false)
        git = Git.open('./', log: log)
        working_branch = git.current_branch

        Open3.popen3('./bin/learn-test-wip save "Automatic test submission" --editor') do |_stdin, _stdout, stderr, wait_thr|
          # while out = stdout.gets do
          #   puts out
          # end
  
          while err = stderr.gets do
            puts err
          end
  
          if wait_thr.value.exitstatus.zero?
            git.push('origin', "wip/#{working_branch}:refs/heads/wip")
            git.config['remote.origin.url'].gsub('.git', '/tree/wip')
            true
          else
            puts 'There was an error running learn-test-wip'
            false
          end
        end
      rescue StandardError => e
        puts e
        false
      end
    end
  end
end
