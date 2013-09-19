module Mist
  class SystemCommand
    def initialize(kernel = Kernel, logger = Mist.logger)
      @kernel = kernel
      @logger = logger
    end

    def run_command_with_output(command)
      logger.debug("Running command '#{command}'")
      kernel.send(:`, command)
    end

    def run_command(command)
      logger.debug("Running command '#{command}'")
      kernel.system(command)
    end

    private

    attr_reader :kernel, :logger
  end
end
