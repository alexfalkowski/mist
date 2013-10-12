require 'spec_helper'

describe Mist::VersionControlExtensions do
  let(:environment) { Spec.environment }

  let(:aws_dev_tools_path) {
    File.join(environment.git_config[:local_path], environment.git_config[:repository_name], '.git', 'AWSDevTools')
  }

  let(:repository_path) {
    File.join(environment.git_config[:local_path], environment.git_config[:repository_name])
  }

  let(:home_path) { Dir.mktmpdir }
  let(:eb_config_file) { File.join(repository_path, '.elasticbeanstalk', 'config') }
  let(:aws_credential_file) { File.join(home_path, '.elasticbeanstalk', 'aws_credential_file') }

  Given { FileUtils.mkpath File.join(repository_path, '.git') }

  context 'setup AWS dev tools' do
    Given(:system_command) { SpecSystemCommand.new }
    Given(:extensions) {
      Mist::VersionControlExtensions.new(environment: environment,
                                         home_path: home_path,
                                         system_command: system_command)
    }
    When { extensions.setup }
    Then { Dir.exists?(aws_dev_tools_path) }
  end

  context 'elastic beanstalk config' do
    Given(:system_command) { SpecSystemCommand.new }
    Given(:extensions) {
      Mist::VersionControlExtensions.new(environment: environment,
                                         home_path: home_path,
                                         system_command: system_command)
    }
    When { extensions.setup }
    Then { File.exists?(eb_config_file) }
    Then { File.read(eb_config_file).include? 'ApplicationName=test' }
    Then { File.read(eb_config_file).include? 'DevToolsEndpoint=git.elasticbeanstalk.us-east-1.amazonaws.com' }
    Then { File.read(eb_config_file).include? 'EnvironmentName=test-QA-A' }
    Then { File.read(eb_config_file).include? 'Region=us-east-1' }
  end

  context 'elastic beanstalk aws credential file' do
    Given(:system_command) { SpecSystemCommand.new }
    Given(:extensions) {
      Mist::VersionControlExtensions.new(environment: environment,
                                         home_path: home_path,
                                         system_command: system_command)
    }
    When { extensions.setup }
    Then { File.exists?(aws_credential_file) }
    Then { File.read(aws_credential_file).include? 'AWSAccessKeyId=AWS_APP_ACCESS_KEY_ID' }
    Then { File.read(aws_credential_file).include? 'AWSSecretKey=AWS_APP_SECRET_KEY' }
  end
end
