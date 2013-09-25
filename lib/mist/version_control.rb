module Mist
  class VersionControl
    def initialize(options = {})
      @environment = options[:environment]
      @system_command = options.fetch(:system_command) { SystemCommand.new }
      @logger = options.fetch(:logger, Mist.logger)
      @extensions = options.fetch(:extensions) {
        Mist::VersionControlExtensions.new(environment: environment,
                                           system_command: system_command,
                                           logger: logger)
      }

      prepare
    end

    def push_latest_version(environment)
      pull_latest_changes
      push_to_aws environment
    end

    private

    attr_reader :environment, :system_command, :logger, :extensions

    def prepare
      clone_repository unless Dir.exists?(repository_path)
      extensions.setup
    end

    def clone_repository
      logger.info('Cloning the repository.')
      Dir.mkdir(repository_path)
      system_command.run_command 'git clone',
                                 environment.git_config[:repository_uri],
                                 repository_path,
                                 '-q'
    end

    def pull_latest_changes
      logger.info('Getting the latest version.')
      Dir.chdir(repository_path) do
        system_command.run_command 'git pull', '-q'
      end
    end

    def push_to_aws(environment)
      logger.info('Pushing to AWS.')
      Dir.chdir(repository_path) do
        system_command.run_command 'git aws.push', "--environment #{environment}", '> /dev/null 2>&1'
      end
    end

    def repository_path
      @repository_path ||= File.join(environment.git_config[:local_path],
                                     environment.git_config[:repository_name])
    end
  end
end
