# frozen_string_literal: true

require 'tmpdir'

# Helpers for creating temporary directories for testing.
module DirectorySpecHelpers
  module_function

  # Creates a directory in a temporary directory which will automatically be
  # destroyed at the end of the spec run. Any block passed to this will be
  # executed with the created directory as the working directory.
  #
  # @return [String] The full path of the directory.
  def directory(name = 'some-dir', &block)
    tmpdir = Dir.mktmpdir.tap do |path|
      Dir.chdir(path) do
        Dir.mkdir(name)
        Dir.chdir(name, &block) if block_given?
      end
    end

    File.join(tmpdir, name)
  end
end
