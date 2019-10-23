module EvilerWinRM
  class CommandManager
    @commands = []

    class << self
      def register_command(instance)
        @commands << instance
      end

      def process_command(str, args, shell)
        if cmd = @commands.find {|cmd| (cmd.class::ALIASES + [cmd.class::NAME]).include? str }
          cmd.shell = shell
          cmd.call(args)
          true
        else
          false
        end
      end

      def autocomplete_suggestions(sigil, str)
        sugg = @commands.select do |cmd|
          cmd.class::NAME.start_with? str || (cmd.class::ALIASES.any? {|a| a.start_with? str })
        end.map {|cmd| cmd.class::NAME }

        if sugg.size == 1
          sugg[0] = sigil + sugg[0]
        else
          sugg
        end
      end

      def find_command(name)
        @commands.find do |cmd|
          cmd.class::NAME == name || cmd.class::ALIASES.any? {|a| a == name }
        end
      end

      def command_name?(str)
        !find_command(str).nil?
      end

      def commands
        @commands
      end
    end
  end
end