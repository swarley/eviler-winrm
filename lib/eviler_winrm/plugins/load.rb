# frozen_string_literal: true

require 'eviler_winrm/command'

class LoadCommand < EvilerWinRM::Command
  NAME = 'load'
  ALIASES = %w[l].freeze
  HELP = 'Load a local PowerShell script on the remote system'
  USAGE = 'load SCRIPT_NAME'
  COMPLETION = proc do |input|
    paths = Dir.glob(File.join(EvilerWinRM::CONNECTION.scripts_path, '*')).select do |path|
      File.basename(path).start_with? input
    end
    paths.map { |path| File.basename(path, '.ps1') }
  end

  def call(args)
    fname = args.shift

    scripts = Dir.glob(File.join(conn.scripts_path, '*'))
    script = scripts.find { |path| File.basename(path, '.ps1') == fname }

    unless script
      EvilerWinRM::LOGGER.error("Script `#{fname}' does not exist")
      return
    end

    begin
      File.new(script, 'r').close
    rescue Errno::EACCES
      EvilerWinRM::LOGGER.error("Cannot open `#{fname}'")
      return
    end

    conn.shell.run(File.read(script))
  end
end
