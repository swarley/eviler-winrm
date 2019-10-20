# frozen_string_literal: true

require 'colorize'
require 'eviler_winrm/command'
require 'eviler_winrm/command_manager'
require 'eviler_winrm/connection'
require 'eviler_winrm/logger'
require 'eviler_winrm/cli'

Gem.find_files("eviler_winrm/plugins/*.rb").each do |path|
  name = File.basename(path, '.rb')
  EvilerWinRM::LOGGER.debug("Loading plugin `#{name}'")
  begin
    require path
  rescue Exception => e
    EvilerWinRM::LOGGER.warn("Failed to load plugin `#{name}'")
    EvilerWinRM::LOGGER.warn(e.message)
  end
end