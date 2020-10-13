require 'fileutils'
require 'git'
require 'logger'
require 'tempfile'

require_relative 'branch'
require_relative 'error'

module LearnTest
  module Git
    module Wip
      class Base < ::Git::Path
        TEMPFILE = '.wip'.freeze
        PREFIX = 'refs/wip/'.freeze

        attr_reader :working_branch, :wip_branch

        def initialize(base:, message:)
          @base = base
          @message = message

          current_branch = @base.current_branch

          @tmp = Tempfile.new(TEMPFILE)
          @working_branch = Branch.new(base: @base, name: current_branch)
          @wip_branch = Branch.new(base: @base, name: "#{PREFIX}#{current_branch}")
        end

        def process!
          if @wip_branch.last_revision
            merge = @base.merge_base(@wip_branch.last_revision, @working_branch.last_revision)
            # Possible Error: "`#{@working_branch}` and `#{@wip_branch}` are unrelated."

            @wip_branch.parent =
              merge == @working_branch.last_revision ? 
                @wip_branch.last_revision :
                @working_branch.last_revision
          else
            @wip_branch.parent = @working_branch.last_revision
          end

          new_tree = build_new_tree(@wip_branch.parent)
          tree_diff = @base.diff(new_tree, @wip_branch.parent)

          raise NoChangesError if tree_diff.count.zero?

          commit = @base.commit_tree(new_tree, parent: @wip_branch.parent)
          # Possible Error: "Cannot record working tree state"

          @base.lib.send(:command, 'update-ref', ['-m', @message, @wip_branch, commit.objectish])
        ensure
          cleanup
          false
        end

        private

        def build_new_tree(wip_parent)
          index = "#{@tmp.path}-index"

          FileUtils.rm(index, force: true)
          FileUtils.cp("#{@base.dir.path}/.git/index", index)

          @base.read_tree(wip_parent)
          @base.lib.send(:command, 'add', ['--update', '--', '.'])
          new_tree_obj = @base.write_tree

          FileUtils.rm(index, force: true)

          new_tree_obj
        end

        def revparse(branch)
          begin
            @base.revparse(branch)
          rescue ::Git::GitExecuteError => e
            yield(e)
          end
        end

        def cleanup
          FileUtils.rm("#{@tmp.path}-*", force: true)
        end
      end
    end
  end
end
