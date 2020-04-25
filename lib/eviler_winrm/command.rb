# frozen_string_literal: true

module EvilerWinRM
  class Command
    attr_reader :name
    attr_accessor :shell

    def call
      raise Exception, 'A command must define a call method'
    end

    def conn
      @conn || EvilerWinRM::CONNECTION
    end

    def self.inherited(klass)
      EvilerWinRM::CommandManager.register_command(klass.new)
    end
  end
end
