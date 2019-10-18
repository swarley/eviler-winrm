require 'progress_bar'
require 'winrm-fs'

class DownloadCommand < EvilerWinRM::Command
  NAME = 'download'
  ALIASES = []
  HELP = 'Download a file from the remote system.'

  def call(args)
    if args.empty?
      EvilerWinRM::LOGGER.error('Please provide a path to a file')
      return
    end

    fname = args.shift
    
    out = conn.shell.run("(Get-Item '#{fname}').length")
    stderr = out.stderr

    if stderr.start_with? 'Cannot find path'
      EvilerWinRM::LOGGER.error("Could not find `#{fname}'")
      return
    elsif stderr.start_with? 'Access is denied'
      EvilerWinRM::LOGGER.error("Access Denied")
      return
    elsif !stderr.empty?
      EvilerWinRM::LOGGER.error("Encountered an unknown error reading `#{fname}'")
      EvilerWinRM::LOGGER.error(stderr)
    end

    size = out.stdout.chomp.to_i

    download_path = args.shift || fname

    begin
      File.new(download_path, 'w+').close
    rescue Errno::EACCES
      EvilerWinRM::LOGGER.error("Unable to open local file `#{download_path}', access denied.")
      return
    end

    file_manager = WinRM::FS::FileManager.new(conn.conn)

    EvilerWinRM::LOGGER.info("Downloading `#{fname}' to `#{download_path}'")

    begin
      progress_bar = ProgressBar.new(size, :bar, :counter, :percentage, :elapsed, :eta)
      file_manager.download(fname, download_path) do |bytes_copied, _|
        progress_bar.increment!(bytes)
      end
      progress_bar.increment! progress_bar.remaining
      EvilerWinRM::LOGGER.info("File downloaded successfully")
    rescue Exception => ex
      EvilerWinRM::LOGGER.error(ex)
    end
  end
end