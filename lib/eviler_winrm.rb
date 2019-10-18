# frozen_string_literal: true

require 'colorize'
require 'eviler_winrm/command'
require 'eviler_winrm/command_manager'
require 'eviler_winrm/connection'
require 'eviler_winrm/logger'
require 'eviler_winrm/cli'

Dir.glob(File.join(File.expand_path('../plugins', __dir__), '*.rb')).each do |file|
  EvilerWinRM::LOGGER.info("Loading plugin #{File.basename file, '.rb'}")
  load file
end