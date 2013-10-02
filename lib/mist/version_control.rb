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
      @dir = options.fetch(:dir, Dir)
      @file = options.fetch(:file, File)

      prepare
    end

    def push_latest_version(environment)
      checkout_latest
      push_to_aws environment
    end

    def push_version(environment, version)
      checkout_version version
      push_to_aws environment
    end

    private

    attr_reader :environment, :system_command, :logger, :extensions, :dir, :file

    def prepare
      clone_repository unless dir.exists?(repository_path)
      extensions.setup
    end

    def checkout_latest
      checkout_master
      pull_latest_changes
    end

    def checkout_version(version)
      checkout_master
      pull_latest_changes
      checkout_commit version
    end

    def checkout_master
      logger.info('Checking out master.')
      dir.chdir(repository_path) do
        system_command.run_command 'git checkout', 'master', '-q'
      end
    end

    def checkout_commit(commit)
      logger.info("Checking out commit '#{commit}'")
      dir.chdir(repository_path) do
        system_command.run_command 'git checkout', commit, '-q'
      end
    end

    def clone_repository
      logger.info('Cloning the repository.')
      dir.mkdir(repository_path)
      system_command.run_command 'git clone',
                                 environment.git_config[:repository_uri],
                                 repository_path,
                                 '-q'
    end

    def pull_latest_changes
      logger.info('Getting the latest version.')
      dir.chdir(repository_path) do
        system_command.run_command 'git pull', '-q'
      end
    end

    def push_to_aws(environment)
      logger.info('Pushing to AWS.')
      dir.chdir(repository_path) do
        system_command.run_command 'git aws.push', "--environment #{environment}", '> /dev/null 2>&1'
      end
    end

    def repository_path
      @repository_path ||= file.join(environment.git_config[:local_path],
                                     environment.git_config[:repository_name])
    end
  end
end
