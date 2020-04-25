# frozen_string_literal: true

require 'base64'

class InvokeBinaryCommand < EvilerWinRM::Command
  NAME = 'exec'
  ALIASES = [].freeze

  def initialize
    @loaded = false
  end

  def call(args)
    unless @loaded
      conn.shell.run(File.read(File.expand_path('../../../data/Invoke-Binary.ps1', __dir__)))
      @loaded = true
    end

    if args.empty?
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

    exe64 = Base64.strict_encode64(File.binread(fname))
    conn.shell.run('Invoke-Binary', [exe64] + args) do |stdout, stderr|
      STDOUT.print(stdout)
      STDERR.print(stderr&.red)
    end
  end
end
