module Mist
  class SystemCommand
    def initialize(options = {})
      @kernel = options.fetch(:kernel, Kernel)
      @logger = options.fetch(:logger, Mist.logger)
    end

    def run_command_with_output(command, *parameters)
      system_command = "#{command} #{parameters.join(' ')}".strip
      logger.debug("Running command '#{system_command}'")
      kernel.send(:`, system_command)
    end

    def run_command(command, *parameters)
      system_command = "#{command} #{parameters.join(' ')}".strip
      logger.debug("Running command '#{system_command}'")
      kernel.system(system_command)
    end

    private

    attr_reader :kernel, :logger
  end
end
