require 'progress_bar'
require 'winrm-fs'

class UploadCommand < EvilerWinRM::Command
  NAME = 'upload'
  ALIASES = []
  HELP = 'Upload a local file to the remote server'

  CHECK_PS_CMD = <<~EOF
    $outfile = '%s'
    Try { [io.file]::OpenWrite((Resolve-Path $outfile).path).close() } Catch { Write-Warning "Unable to write to output file $outputfile" }
  EOF

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

    out = conn.shell.run(format(CHECK_PS_CMD, upload_path))

    unless out.stderr.empty?
      EvilerWinRM::LOGGER.error('Unable to create remote file, access denied.')
      return
    end
    
    begin
      progress_bar = ProgressBar.new(File.size(fname), :bar, :counter, :percentage, :elapsed, :eta)
      file_manager.upload(fname, upload_path) do |bytes_copied, _|
        progress_bar.increment!
      end
      progress_bar.increment! progress_bar.remaining
      EvilerWinRM::LOGGER.info("File uploaded successfully")
    rescue Exception => ex
      EvilerWinRM::LOGGER.error(ex)
    end
  end
end