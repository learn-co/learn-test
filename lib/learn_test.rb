# frozen_string_literal: true

require 'fileutils'
require 'oj'
require 'colorize'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'csharp' => 'CSharp',
  'csharp_nunit' => 'CSharpNunit',
  'nodejs' => 'NodeJS',
  'phantomjs' => 'PhantomJS'
)
loader.setup

module LearnTest
  def self.root
    File.dirname __dir__
  end

  def self.bin
    File.join root, 'bin'
  end
end
