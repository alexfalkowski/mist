module Mist
  class VersionControlExtensions
    def initialize(options = {})
      @environment = options[:environment]
      @home_path = options.fetch(:home_path) { Dir.home }
      @system_command = options.fetch(:system_command) { SystemCommand.new }
      @logger = options.fetch(:logger, Mist.logger)
      @eb_tool = options.fetch(:eb_tool) { Mist::ElasticBeanstalkTool.new }
      @dir = options.fetch(:dir, Dir)
      @file = options.fetch(:file, File)
      @file_utils = options.fetch(:file_utils, FileUtils)
    end

    def setup
      add_deploy_extensions unless dir.exists?(aws_dev_tools_path)
      write_eb_config_file unless file.exists?(eb_config_file)
      write_aws_credential_file unless file.exists?(aws_credential_file)
    end

    private

    attr_reader :environment, :home_path, :system_command, :logger, :eb_tool, :dir, :file, :file_utils

    def add_deploy_extensions
      logger.info('Adding AWS deployment tools.')
      dir.chdir(repository_path) do
        system_command.run_command aws_dev_tools_script_path
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
      dir_name = file.dirname(path)
      file_utils.mkpath dir_name unless dir.exists?(dir_name)

      file.open(path, 'w+') { |file|
        file.write contents
      }
    end

    def repository_path
      @repository_path ||= file.join(environment.git_config[:local_path],
                                     environment.git_config[:repository_name])
    end

    def eb_config_file
      @eb_config_file ||= file.join(repository_path, elastic_beanstalk_dir_name, 'config')
    end

    def aws_credential_file
      @aws_credential_file ||= file.join(home_path, elastic_beanstalk_dir_name, 'aws_credential_file')
    end

    def aws_dev_tools_path
      @aws_dev_tools_path ||= file.join(repository_path, '.git', aws_dev_tools_dir_name)
    end

    def aws_dev_tools_script_path
      @aws_dev_tools_script_path ||= file.join(eb_tool.tool_path,
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
