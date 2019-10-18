# frozen_string_literal: true

require 'colorize'
require 'eviler_winrm/command_manager'
require 'eviler_winrm/cli'
require 'readline'
require 'resolv'
require 'shellwords'
require 'winrm'

module EvilerWinRM  
  class Connection
    attr_reader :conn
    attr_reader :shell
    attr_accessor :prompt

    def initialize(args)
      @args = args
      @prompt = args[:prompt]

      ip = args[:ip]

      begin
        ip = Resolv.getaddress(args[:ip])
      rescue Resolv::ResolvError
        LOGGER.warn("Unable to resolve IP for `#{args[:ip]}'")
      end

      LOGGER.debug("Resolving `#{args[:ip]}' to #{ip}") if ip != args[:ip]

      proto = args.ssl? ? 'https' : 'http'
      endpoint = args[:url].delete_prefix('/')
      port = args[:port] || (args.ssl? ? 5986 : 5985)
      url = format('%s://%s:%i/%s', proto, ip, port, endpoint)

      if args[:ssl]
        keys = { client_cert: args[:pub_key], client_key: args[:priv_key] }
        @conn = ::WinRM::Connection.new(
          endpoint: url,
          user: args[:user],
          password: args[:password],
          no_ssl_peer_verification: true,
          transport: :ssl,
          **keys.compact
        )
      else
        @conn = ::WinRM::Connection.new(
          endpoint: url,
          user: args[:user],
          password: args[:password],
          no_ssl_peer_verification: true
        )
      end
    end

    def interactive
      @conn.shell(:powershell) do |shell|
        @shell = shell
        loop do
          compiled_prompt = shell.run("echo \"#{@prompt}\"").output.chomp.gsub('_EVIL_COLOR_', "\e")
          command = Readline.readline(compiled_prompt, true)

          if command.start_with? '>>'
            cmd, args = command.delete_prefix('>>').lstrip.split(' ', 2)
            
            unless EvilerWinRM::CommandManager.process_command(cmd, args&.shellsplit, shell)
              LOGGER.error("No command `#{cmd}'")
            end
            next
          end
          shell.run(command) do |stdout, stderr|
            STDOUT.print(stdout)
            STDERR.print(stderr&.red)
          end
        end
      end
    rescue SignalException
      LOGGER.info('Interrupt recieved. Exiting')
    end
  end
end
