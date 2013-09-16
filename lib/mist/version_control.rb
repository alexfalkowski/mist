module Mist
  class VersionControl
    attr_reader :env_variables, :home_path, :kernel

    def initialize(env_variables, home_path = Dir.home, kernel = Kernel)
      @env_variables, @home_path, @kernel = env_variables, home_path, kernel
      prepare
    end

    def deploy_latest_version(environment)
      pull_latest_changes
      push_to_aws environment
    end

    private

    def prepare
      clone_repository unless Dir.exists?(repository_path)
      add_deploy_extensions unless Dir.exists?(aws_dev_tools_path)
      write_eb_config_file unless File.exists?(eb_config_file)
      write_aws_credential_file unless File.exists?(aws_credential_file)
    end

    def add_deploy_extensions
      Dir.chdir(repository_path) do
        kernel.system aws_dev_tools_script_path
      end
    end

    def clone_repository
      Dir.mkdir(repository_path)
      kernel.system "git clone #{git[:repository_uri]} #{repository_path}"
    end

    def pull_latest_changes
      Dir.chdir(repository_path) do
        kernel.system 'git pull'
      end
    end

    def push_to_aws(environment)
      Dir.chdir(repository_path) do
        kernel.system "git aws.push --environment #{environment}"
      end
    end

    def write_eb_config_file
      eb_config = env_variables[:aws][:eb]
      contents = %Q[
        [global]
        ApplicationName=#{eb_config[:application_name]}
        DevToolsEndpoint=#{eb_config[:dev_tools_endpoint]}
        EnvironmentName=#{eb_config[:environments].first[:name]}
        Region=#{eb_config[:region]}
      ]

      write_file eb_config_file, contents
    end

    def write_aws_credential_file
      aws_config = env_variables[:aws]
      contents = %Q[
        AWSAccessKeyId=#{aws_config[:access_key_id]}
        AWSSecretKey=#{aws_config[:secret_key]}
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
      @repository_path ||= File.join(git[:local_path], git[:repository_name])
    end

    def eb_config_file
      @eb_config_file ||= File.join(repository_path, elastic_beanstalk_dir_name, 'config')
    end

    def aws_credential_file
      @aws_credential_file ||= File.join(home_path, elastic_beanstalk_dir_name, 'aws_credential_file')
    end

    def elastic_beanstalk_dir_name
      '.elasticbeanstalk'
    end

    def aws_dev_tools_path
      @aws_dev_tools_path ||= File.join(repository_path, '.git', 'AWSDevTools')
    end

    def aws_dev_tools_script_path
      @aws_dev_tools_script_path ||= File.join(ENV['CLI_LOCATION'],
                                               'AWSDevTools',
                                               'Linux',
                                               'AWSDevTools-RepositorySetup.sh')
    end

    def git
      env_variables[:git]
    end
  end
end
