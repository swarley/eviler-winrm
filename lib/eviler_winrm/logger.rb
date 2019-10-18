# frozen_string_literal: true

require 'logger'

module EvilerWinRM
  class LogFormatter < ::Logger::Formatter
    SEVERITIES = {
      'DEBUG' => :white,
      'ERROR' => :red,
      'FATAL' => :magenta,
      'INFO' => :yellow,
      'WARN' => :light_red
    }
    def call(sev, time, prog, msg)
      "[#{sev}] #{msg}\n".send(SEVERITIES[sev] || :white)
    end
  end

  LOGGER = Logger.new(STDOUT)
  LOGGER.formatter = LogFormatter.new
  LOGGER.level = :info
end
