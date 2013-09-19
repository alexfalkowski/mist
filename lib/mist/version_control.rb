module Mist
  class VersionControl
    def initialize(options = {})
      @environment = options[:environment]
      @home_path = options.fetch(:home_path, Dir.home)
      @system_command = options.fetch(:system_command, SystemCommand.new)
      @logger = options.fetch(:logger, Mist.logger)
      @cli_location = options.fetch(:cli_location, ENV['CLI_LOCATION'])

      prepare
    end

    def push_latest_version(environment)
      pull_latest_changes
      push_to_aws environment
    end

    private

    attr_reader :environment, :home_path, :system_command, :logger, :cli_location

    def prepare
      clone_repository unless Dir.exists?(repository_path)
      add_deploy_extensions unless Dir.exists?(aws_dev_tools_path)
      write_eb_config_file unless File.exists?(eb_config_file)
      write_aws_credential_file unless File.exists?(aws_credential_file)
    end

    def add_deploy_extensions
      logger.info('Adding AWS deployment tools.')
      Dir.chdir(repository_path) do
        system_command.run_command aws_dev_tools_script_path
      end
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

    def write_eb_config_file
      contents = %Q[
        [global]
        ApplicationName=#{environment.eb_config[:application_name]}
        DevToolsEndpoint=#{environment.eb_config[:dev_tools_endpoint]}
        EnvironmentName=#{environment.eb_config[:environments].first[:name]}
        Region=#{environment.eb_config[:region]}
      ]

      write_file eb_config_file, contents
    end

    def write_aws_credential_file
      contents = %Q[
        AWSAccessKeyId=#{environment.eb_config[:access_key_id]}
        AWSSecretKey=#{environment.eb_config[:secret_key]}
      ]

      write_file aws_credential_file, contents
    end

    def write_file(path, contents)
      dir = File.dirname(path)
      FileUtils.mkpath dir unless Dir.exists?(dir)

      File.open(path, 'w+') { |file|
        file.write contents
      }
    end

    def repository_path
      @repository_path ||= File.join(environment.git_config[:local_path],
                                     environment.git_config[:repository_name])
    end

    def eb_config_file
      @eb_config_file ||= File.join(repository_path, elastic_beanstalk_dir_name, 'config')
    end

    def aws_credential_file
      @aws_credential_file ||= File.join(home_path, elastic_beanstalk_dir_name, 'aws_credential_file')
    end

    def aws_dev_tools_path
      @aws_dev_tools_path ||= File.join(repository_path, '.git', aws_dev_tools_dir_name)
    end

    def aws_dev_tools_script_path
      @aws_dev_tools_script_path ||= File.join(cli_location,
                                               aws_dev_tools_dir_name,
                                               'Linux',
                                               'AWSDevTools-RepositorySetup.sh')
    end

    def elastic_beanstalk_dir_name
      '.elasticbeanstalk'
    end

    def aws_dev_tools_dir_name
      'AWSDevTools'
    end
  end
end
