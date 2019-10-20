require 'eviler_winrm/command'

class LoadCommand < EvilerWinRM::Command
  NAME = 'load'
  ALIASES = %w[l]
  HELP = 'Load a local PowerShell script on the remote system'

  def call(args)
    fname = args.shift

    unless File.exist? fname
      EvilerWinRM::LOGGER.error("Script `#{fname}' does not exist")
      return
    end

    begin
      File.new(fname, 'r').close
    rescue Errno::EACCES
      EvilerWinRM::LOGGER.error("Cannot open `#{fname}'")
      return
    end
    
    conn.shell.run(File.read(args.first))
  end
end