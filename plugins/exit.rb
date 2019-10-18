class ExitCommand < EvilerWinRM::Command
  NAME = 'exit'
  ALIASES = []
  HELP = 'Exit the shell'

  def call(_)
    puts "Exiting".red
    exit
  end
end