require 'spec_helper'

describe Mist::VersionControl do
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

  context 'clone repository' do
    When(:version_control) { Mist::VersionControl.new(environment, home_path) }
    Then { Dir.exists?(repository_path) }
  end

  context 'setup AWS dev tools' do
    When(:version_control) { Mist::VersionControl.new(environment, home_path) }
    Then { Dir.exists?(aws_dev_tools_path) }
  end

  context 'elastic beanstalk config' do
    When(:version_control) { Mist::VersionControl.new(environment, home_path) }
    Then { File.exists?(eb_config_file) }
    Then { File.read(eb_config_file).include? 'ApplicationName=PINCHme-US' }
    Then { File.read(eb_config_file).include? 'DevToolsEndpoint=git.elasticbeanstalk.us-east-1.amazonaws.com' }
    Then { File.read(eb_config_file).include? 'EnvironmentName=PINCHme-US-QA-A' }
    Then { File.read(eb_config_file).include? 'Region=us-east-1' }
  end

  context 'elastic beanstalk aws credential file' do
    When(:version_control) { Mist::VersionControl.new(environment, home_path) }
    Then { File.exists?(aws_credential_file) }
    Then { File.read(aws_credential_file).include? 'AWSAccessKeyId=AWS_APP_ACCESS_KEY_ID' }
    Then { File.read(aws_credential_file).include? 'AWSSecretKey=AWS_APP_SECRET_KEY' }
  end

  context 'deploy latest version' do
    Given(:system_command) { double('SystemCommand', run_command: nil) }
    Given(:version_control) { Mist::VersionControl.new(environment, home_path, system_command) }
    When { version_control.push_latest_version('test') }
    Then { expect(system_command).to have_received(:run_command).with('git pull > /dev/null 2>&1') }
    Then { expect(system_command).to have_received(:run_command).with('git aws.push --environment test > /dev/null 2>&1') }
  end
end
