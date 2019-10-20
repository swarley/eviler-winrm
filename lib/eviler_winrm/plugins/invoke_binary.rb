require 'base64'

class InvokeBinaryCommand < EvilerWinRM::Command
  NAME = 'Invoke-Binary'
  ALIASES = []

  def call(args)
    if args.size < 1
      EvilerWinRM::LOGGER.error('Please provide an executable to invoke')
      return
    end

    fname = args.shift
    unless File.exist? fname
      EvilerWinRM::LOGGER.error('Executable does not exist')
      return
    end

    begin
      File.new(fname, 'rb').close
    rescue Erron::EACCES
      EvilerWinRM::LOGGER.error('Unable to open executable')
      return
    end

    exe_64 = Base64.strict_encode64(File.binread(fname))
    conn.shell.run("Invoke-Binary", [exe_64] + args) do |stdout, stderr|
      STDOUT.print(stdout)
      STDERR.print(stderr&.red)
    end
  end
end