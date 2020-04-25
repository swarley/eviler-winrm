# frozen_string_literal: true

class ReloadCommand < EvilerWinRM::Command
  NAME = 'reload'
  ALIASES = [].freeze
  HELP = 'Reload a plugin based on file name'

  def call(args)
    load "plugins/#{args.first}.rb"
  end
end
