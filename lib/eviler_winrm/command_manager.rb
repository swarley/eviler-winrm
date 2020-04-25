# frozen_string_literal: true

module EvilerWinRM
  class CommandManager
    @commands = []

    class << self
      def register_command(instance)
        @commands << instance
      end

      def process_command(str, args, shell)
        if (command = @commands.find { |cmd| (cmd.class::ALIASES + [cmd.class::NAME]).include? str })
          command.shell = shell
          command.call(args)
          true
        else
          false
        end
      end

      def autocomplete_suggestions(sigil, str)
        sugg = @commands.select do |cmd|
          cmd.class::NAME.start_with?(str) || (cmd.class::ALIASES.any? { |a| a.start_with? str })
        end
        sugg.map! { |cmd| cmd.class::NAME }

        if sugg.size == 1
          sugg[0] = sigil + sugg[0]
        else
          sugg
        end
      end

      def find_command(name)
        @commands.find do |cmd|
          cmd.class::NAME == name || cmd.class::ALIASES.any? { |a| a == name }
        end
      end

      def command_name?(str)
        !find_command(str).nil?
      end

      attr_reader :commands
    end
  end
end
