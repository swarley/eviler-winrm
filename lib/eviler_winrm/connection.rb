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
    attr_accessor :sigil
    attr_reader :scripts_path
    attr_reader :args

    def initialize(args)
      @args = args
      @prompt = args[:prompt]
      @sigil = args[:sigil]
      @scripts_path = args[:scripts]
      ip = args[:ip]

      begin
        ip = Resolv.getaddress(args[:ip])
        LOGGER.debug("Resolving `#{args[:ip]}' to #{ip}") if ip != args[:ip]
      rescue Resolv::ResolvError
        LOGGER.warn("Unable to resolve IP for `#{args[:ip]}'")
      end

      proto = args[:ssl] ? 'https' : 'http'
      endpoint = args[:url].delete_prefix('/')
      port = args[:port] || (args[:ssl] ? 5986 : 5985)
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
      EvilerWinRM::LOGGER.info('Establishing connection')
      
      Thread.new do
        sleep 5
        next if @connected
        EvilerWinRM::LOGGER.warn("It's taking a while to connect")
        sleep 10
        next if @connected
        EvilerWinRM::LOGGER.error('Unable to connect')
        exit
      end

      @conn.shell(:powershell) do |shell|
        # We can't be sure that we're connected until a command returns
        shell.run('echo Health check')
        @connected = true

        EvilerWinRM::LOGGER.info('Connected')
        @shell = shell
        Readline.completer_word_break_characters = "\"' "
        Readline.completion_append_character = ''
        Readline.completion_proc = proc do |buff|
          if buff.start_with?(@sigil) && Readline.line_buffer.split.size == 1
            cmd = buff.delete_prefix(@sigil)
            EvilerWinRM::CommandManager.autocomplete_suggestions(@sigil, cmd)
          
          elsif (cmd = EvilerWinRM::CommandManager.find_command(Readline.line_buffer.delete_prefix(@sigil).split[0]))
            klass = cmd.class
            klass::COMPLETION.call(buff) if klass.const_defined? :COMPLETION
          
          else
            maybe_cmd = Readline.line_buffer.split.first

            if buff[0] == '-'
              maybe_cmd = Readline.line_buffer.split.first
              output = shell.run("(Get-Command #{maybe_cmd}).Parameters.Keys")
              output.stdout.lines.select {|x| x.start_with? buff[1..-1] }.map {|x| '-' + x.chomp }
            else
              EvilerWinRM.remote_dir_completion(buff)
            end
          end
        end

        loop do
          compiled_prompt = shell.run("echo \"#{@prompt}\"").output.chomp.gsub('_EVIL_COLOR_', "\e")
          command = Readline.readline(compiled_prompt, true)

          if command.start_with? @sigil
            cmd, args = command.delete_prefix(@sigil).lstrip.split(' ', 2)
            
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
      print "\n"
      LOGGER.info('Interrupt recieved. Exiting')
    end
  end
end
