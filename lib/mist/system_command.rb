module Mist
  class SystemCommand
    attr_reader :kernel

    def initialize(kernel = Kernel)
      @kernel = kernel
    end

    def run_command_with_output(command)
      Mist.logger.debug("Running command '#{command}'")
      kernel.send(:`, command)
    end

    def run_command(command)
      Mist.logger.debug("Running command '#{command}'")
      kernel.system(command)
    end
  end
end
