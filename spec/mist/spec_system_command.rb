class SpecSystemCommand < Mist::SystemCommand
  def run_command_with_output(command, *parameters)
    super
  end

  def run_command(command, *parameters)
    if command == 'git clone'
      FileUtils.mkpath File.join(parameters[1], '.git')
    else
      super
    end
  end
end
