# frozen_string_literal: true

require 'slop'

module Slop
  class FileOption < Option
    def call(value)
      path = Pathname(value)
      raise Error, "File `#{path}' does not exist" unless path.exist?
      raise Error, "`#{path}' is not a file" unless path.file?

      path.expand_path
    end
  end

  class DirOption < Option
    def call(value)
      path = Pathname(value)
      raise Error, "Directory `#{path}' does not exist" unless path.exist?
      raise Error, "`#{path}' is not a directory" unless path.directory?

      path.expand_path
    end
  end
end
