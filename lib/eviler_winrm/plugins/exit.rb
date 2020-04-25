# frozen_string_literal: true

class ExitCommand < EvilerWinRM::Command
  NAME = 'exit'
  ALIASES = [].freeze
  HELP = 'Exit the shell'

  def call(_)
    puts 'Exiting'.red
    exit
  end
end
