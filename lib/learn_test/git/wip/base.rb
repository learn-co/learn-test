# frozen_string_literal: true

require 'fileutils'
require 'git'
require 'logger'
require 'tempfile'

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
          @success = nil

          current_branch = @base.current_branch

          raise NoCommitsError, 'master' if current_branch.nil? # TODO: Swap to `main`?

          @tmp = Tempfile.new(TEMPFILE)
          @working_branch = Branch.new(base: @base, name: current_branch)
          @wip_branch = Branch.new(base: @base, name: "#{PREFIX}#{current_branch}")
        end

        def process!
          if @wip_branch.last_revision
            merge = @base.merge_base(@wip_branch.last_revision, @working_branch.last_revision)

            @wip_branch.parent =
              merge == @working_branch.last_revision ? 
                @wip_branch.last_revision :
                @working_branch.last_revision
          else
            @wip_branch.parent = @working_branch.last_revision
          end

          new_tree = build_new_tree(@wip_branch.parent)
          @base.diff(new_tree, @wip_branch.parent)

          # tree_diff = @base.diff(new_tree, @wip_branch.parent)
          # raise NoChangesError, @wip_branch if tree_diff.count.zero?

          commit = @base.commit_tree(new_tree, parent: @wip_branch.parent)

          @base.lib.send(:command, 'update-ref', ['-m', @message, @wip_branch, commit.objectish])

          @success = true
        ensure
          cleanup
        end

        def success?
          @success
        end

        private

        def build_new_tree(wip_parent)
          index = "#{@tmp.path}-index"

          FileUtils.rm(index, force: true)
          FileUtils.cp("#{@base.dir.path}/.git/index", index)

          @base.read_tree(wip_parent)
          @base.lib.send(:command, 'add', ['--update', '--', '.'])
          @base.add(all: true)

          new_tree_obj = @base.write_tree

          FileUtils.rm(index, force: true)

          new_tree_obj
        end

        def cleanup
          FileUtils.rm("#{@tmp.path}-*", force: true)
        end
      end
    end
  end
end
