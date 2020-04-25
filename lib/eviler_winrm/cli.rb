# frozen_string_literal: true

require 'slop'
require 'eviler_winrm/connection'
require 'eviler_winrm/cli/options'
require 'eviler_winrm/logger'
require 'eviler_winrm/version'
require 'yaml'

module EvilerWinRM
  GET_USER_PROMPT = '$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)'
  DEFAULT_PROMPT = [
    ('[' + GET_USER_PROMPT + '@$env:ComputerName]').green,
    '$(Get-Location)> '.blue
  ].join(' ').gsub("\e", '_EVIL_COLOR_')

  begin
    DEFAULT_ARGS = {
      sigil: '>>',
      prompt: EvilerWinRM::DEFAULT_PROMPT,
      url: '/wsman',
      verbose: 1
    }.freeze

    OPTIONS = Slop::Options.new
    OPTIONS.yield_self do |o|
      o.file '-c', '--pub-key', 'Path to public key certificate'
      o.string '-C', '--sigil', 'Set the sigil to indicate a command'
      o.on '-d', '--disable-color', 'Disable colorization of output' do
        String.disable_colorization = true
      end
      o.dir '-e', '--executables', 'C# executables local path'
      o.file '-E', '--eviler-profile', 'A user profile to load'
      o.on '-h', '--help', 'Display this help message' do
        puts o
        exit
      end
      o.string '-H', '--hash', 'NTLM Hash'
      o.string '-i', '--ip', 'Remote host IP or hostname'
      o.file '-k', '--priv-key', 'Path to private key certificate'
      o.string '-p', '--password', 'Password'
      o.string '-P', '--port', 'Remote host port'
      o.string '-q', '--prompt', 'Set prompt'
      o.string '-r', '--realm', 'Kerberos Realm'
      o.dir '-s', '--scripts', 'Powershell scripts local path'
      o.string '-S', '--ssl', 'Enable SSL'
      o.string '-u', '--user', 'Username'
      o.string '-U', '--url', 'Remote endpoint'
      o.on '-v', '--version', 'Show version' do
        puts "EvilerWinRM v#{VERSION}"
        exit
      end

      o.string '-V', '--verbose', 'Set verbose level', default: 1 do |str|
        log_levels = {}
        Logger::Severity.constants.each do |level|
          log_levels[level] = Logger::Severity.const_get(level)
        end

        if log_levels.include? str.upcase.to_sym
          level = str.upcase.to_sym
          _, value = log_levels[level]

          LOGGER.level = level
          LOGGER.debug("Log level set to #{level} (#{value})")
        else
          level = str.to_i
          key, = log_levels.find { |_, v| v == level }

          LOGGER.level = level
          LOGGER.debug("Log level set to #{key || '????'} (#{str.to_i})")
        end
      end
    end
    PARSER = Slop::Parser.new(OPTIONS)
    args = DEFAULT_ARGS
    slop_args = PARSER.parse(ARGV).to_h

    args.merge!(YAML.load_file(slop_args[:eviler_profile])) if slop_args[:eviler_profile]

    ARGS = args.merge slop_args.compact
  rescue Slop::Error => e
    puts e.message
    puts OPTIONS
    exit
  end
end
