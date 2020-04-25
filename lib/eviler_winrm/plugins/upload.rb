# frozen_string_literal: true

require 'progress_bar'
require 'winrm-fs'

class UploadCommand < EvilerWinRM::Command
  NAME = 'upload'
  ALIASES = [].freeze
  HELP = 'Upload a local file to the remote server'
  USAGE = 'upload <LOCAL PATH> [REMOTE PATH]'
  COMPLETION = proc do |input|
    begin
      curr_args = Readline.line_buffer.shellsplit[1..-1]
    rescue StadnardError
      before, _, curr_input = Readline.line_buffer.rpartition(/[\"\']/)
      curr_args = before.shellsplit << curr_input
    end

    pos = curr_args.length
    pos += 1 if input.empty?

    if pos <= 1
      EvilerWinRM.local_dir_completion(input)
    elsif pos == 2
      EvilerWinRM.remote_dir_completion(input)
    else
      []
    end
  end

  CHECK_PS_CMD = <<~CMD
    ((Get-Acl %s).Access | ?{$_.IdentityReference -match $env:userName} | Select FileSystemRights).FileSystemRights
  CMD

  def call(args)
    if args.empty?
      EvilerWinRM::LOGGER.error('Please provide a path to a file')
      return
    end

    fname = args.shift

    if !File.exist?(fname)
      EvilerWinRM::LOGGER.error("File `#{fname}' does not exist")
      return
    elsif !File.readable?(fname)
      EvilerWinRM::LOGGER.error("Unable to read `#{fname}'")
      return
    end

    upload_path = args.shift || fname

    file_manager = WinRM::FS::FileManager.new(conn.conn)

    EvilerWinRM::LOGGER.info("Uploading `#{fname}' to `#{upload_path}'")

    out = conn.shell.run(format(CHECK_PS_CMD, upload_path.rpartition(%r{[\\/]}).first))
    if out.stdout.empty?
      EvilerWinRM::LOGGER.error('Unable to create remote file, access denied.')
      return
    end

    begin
      # Progress bars are being weird. temporarily disabled
      # progress_bar = ProgressBar.new(File.size(fname), :bar, :counter, :percentage, :elapsed, :eta)
      file_manager.upload(fname, upload_path) do |bytes_copied, _|
        # progress_bar.increment!(bytes_copied)
      end
      # progress_bar.increment! progress_bar.remaining if progress_bar.remaining
      EvilerWinRM::LOGGER.info('File uploaded successfully')
    rescue StandardError => e
      EvilerWinRM::LOGGER.error(e)
    end
  end
end
