# frozen_string_literal: true

require 'colorize'
require 'eviler_winrm/command'
require 'eviler_winrm/command_manager'
require 'eviler_winrm/connection'
require 'eviler_winrm/logger'
require 'eviler_winrm/cli'

Gem.find_files('eviler_winrm/plugins/*.rb').each do |path|
  name = File.basename(path, '.rb')
  EvilerWinRM::LOGGER.debug("Loading plugin `#{name}'")
  begin
    require path
  rescue StandardError => e
    EvilerWinRM::LOGGER.warn("Failed to load plugin `#{name}'")
    EvilerWinRM::LOGGER.warn(e.message)
  end
end

module EvilerWinRM
  def self.remote_dir_completion(buffer)
    base_path, sep, = buffer.rpartition(%r{[\\/]})
    output = EvilerWinRM::CONNECTION.shell.run("Get-ChildItem -Name #{buffer}*")
    output.stdout.lines.map { |line| base_path + sep + line.chomp }
  end

  def self.local_dir_completion(buffer)
    Dir.glob(buffer + '*')
  end
end
