class ReloadCommand < EvilerWinRM::Command
  NAME = 'reload'
  ALIASES = []
  HELP = 'Reload a plugin based on file name'
  
  def call(args)
    load "plugins/#{args.first}.rb"
  end
end