class PromptCommand < EvilerWinRM::Command
  NAME = 'prompt'
  ALIASES = %w[>]
  HELP = 'Change the prompt. Formatted using %{color} interpolation. `%{blue}user %{green}path>\''
  USAGE = 'prompt "%{blue}[$env:userName] %{green}(Get-Location)>"'
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
  }
  COMPLETION = proc do |input|
    input = input.delete_prefix('%{').delete_suffix('}')
    COLORS.keys.map(&:to_s).select {|k| k.start_with? input }.collect {|k| "%{#{k}}" }
  end

  def call(args)
    prompt_test = format(args[0] + "_EVIL_COLOR_[0m", COLORS)

    conn.shell.run("echo \"#{prompt_test}\"") do |stdout, stderr|
      unless stderr
        conn.prompt = prompt_test
        puts "Success".green
      else
        puts "Recieved an error echoing your prompt:".red
        puts stderr.red
      end
      return
    end
  end
end