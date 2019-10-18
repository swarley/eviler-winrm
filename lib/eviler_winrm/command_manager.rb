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
    end
  end
end