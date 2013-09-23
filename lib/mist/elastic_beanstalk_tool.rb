module Mist
  class ElasticBeanstalkTool
    ELB_URI = 'https://s3.amazonaws.com/elasticbeanstalk/cli/'

    CLI_VERSION = 'AWS-ElasticBeanstalk-CLI-2.5.1'

    FILE_NAME = "#{CLI_VERSION}.zip"

    def initialize(options = {})
      @home_path = options.fetch(:home_path) { Dir.home }
      @file = options.fetch(:file, File)
      @file_utils = options.fetch(:file_utils, FileUtils)
      @dir = options.fetch(:dir, Dir)
      @system_command = options.fetch(:system_command) { SystemCommand.new }
      @logger = options.fetch(:logger, Mist.logger)
    end

    def setup
      unless file.exists?(tool_path)
        download_tool
        unzip_tool

        logger.info("Successfully setup tool '#{CLI_VERSION}'")
      end
    end

    def cleanup
      if dir.exists?(tool_path)
        file_utils.rm_rf dir.glob("#{tool_path}*")
        logger.info("Successfully cleaned up tool '#{CLI_VERSION}'")
      end
    end

    def tool_path
      file.join(home_path, CLI_VERSION)
    end

    def tool_file_path
      file.join(home_path, FILE_NAME)
    end

    private

    attr_reader :home_path, :file, :file_utils, :dir, :system_command, :logger

    def download_tool
      system_command.run_command('curl', '-s', "-o #{tool_file_path}", URI.join(ELB_URI, FILE_NAME).to_s)
      logger.info("Successfully downloaded tool '#{CLI_VERSION}'")
    end

    def unzip_tool
      system_command.run_command('unzip', '-o', '-q', "-d #{home_path}", tool_file_path)
      logger.info("Successfully extracted tool '#{CLI_VERSION}'")
    end
  end
end
