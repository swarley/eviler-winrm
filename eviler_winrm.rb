# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))

require 'eviler_winrm'

module EvilerWinRM
  CONNECTION = EvilerWinRM::Connection.new(EvilerWinRM::ARGS)
end

EvilerWinRM::CONNECTION.interactive
