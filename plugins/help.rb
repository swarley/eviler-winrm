class HelpCommand < EvilerWinRM::Command
  NAME = 'help'
  ALIASES = %w[?]
  HELP = 'Display help messages for commands'

  def call(args)
    cmd_name = args.first
    cmd = EvilerWinRM::CommandManager.commands.find do |c|
      (c.class::ALIASES + [c.class::NAME]).map(&:downcase).include? cmd_name.downcase
    end

    if cmd.nil?
      puts "No command `#{cmd_name}'"
      return
    end

    klass = cmd.class
    puts klass::HELP if klass.const_defined? :HELP
    puts klass::USAGE if klass.const_defined? :USAGE
  end
end