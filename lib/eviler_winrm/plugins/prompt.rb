class PromptCommand < EvilerWinRM::Command
  NAME = 'prompt'
  ALIASES = %w[>]
  HELP = 'Change the prompt. Formatted using %{color} interpolation. `%{blue}user %{green}path>\''
  
  COLORS = {
    :black =>"_EVIL_COLOR_[30m",
    :red => "_EVIL_COLOR_[31m",
    :green =>"_EVIL_COLOR_[32m",
    :yellow => "_EVIL_COLOR_[33m",
    :blue => "_EVIL_COLOR_[34m",
    :magenta => "_EVIL_COLOR_[35m",
    :cyan => "_EVIL_COLOR_[36m",
    :white => "_EVIL_COLOR_[37m",
    :default => "_EVIL_COLOR_[39m",
    :bold => "_EVIL_COLOR_[1m",
    :italics => "_EVIL_COLOR_[3m",
    :underline => "_EVIL_COLOR_[4m"
  }

  def call(args)
    conn.prompt = format(args[0] + "_EVIL_COLOR_[0m", COLORS)
  end
end