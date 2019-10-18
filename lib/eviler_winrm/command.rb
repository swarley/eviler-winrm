module EvilerWinRM
  class Command
    attr_reader :conn
    attr_reader :name
    attr_reader :aliases
    attr_accessor :shell

    def initialize
      @aliases = []
    end

    def conn
      EvilerWinRM::CONNECTION
    end

    def self.inherited(klass)
      EvilerWinRM::CommandManager.register_command(klass.new)
    end
  end
end
