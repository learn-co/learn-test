# frozen_string_literal: true

require 'fileutils'

module LearnTest
  module Git
    module Wip
      class Reference < Branch
        attr_accessor :parent

        PREFIX = 'refs/wip/'

        def initialize(base:, name:)
          dir = File.join(base.repo.path, PREFIX)
          file = File.join(dir, name)
          sha = base.log(1)[0].sha

          FileUtils.mkdir_p(dir, { mode: 0755 }) unless Dir.exist?(dir)
          File.open(file, 'w+') { |f| f.puts sha } unless File.exist?(file)

          super(base: base, name: "#{PREFIX}#{name}")
        end
      end
    end
  end
end
