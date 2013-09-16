require 'spec_helper'

describe Mist::VersionControl do
  let(:variables) {
    {
        git: {
            repository_name: 'PINCHme',
            repository_uri: 'git@github.com:railstutorial/sample_app.git',
            local_path: Dir.mktmpdir
        },
        aws: {
            access_key_id: 'access_key_id',
            secret_key: 'secret_key',

            eb: {
                application_name: 'application_name',
                dev_tools_endpoint: 'dev_tools_endpoint',
                environments: [
                    {name: 'environment-1'},
                    {name: 'environment-2'},
                ],
                region: 'region'
            }
        }
    }
  }

  let(:aws_dev_tools_path) {
    File.join(variables[:git][:local_path], variables[:git][:repository_name], '.git', 'AWSDevTools')
  }

  let(:repository_path) {
    File.join(variables[:git][:local_path], variables[:git][:repository_name])
  }

  let(:home_path) { Dir.mktmpdir }
  let(:eb_config_file) { File.join(repository_path, '.elasticbeanstalk', 'config') }
  let(:aws_credential_file) { File.join(home_path, '.elasticbeanstalk', 'aws_credential_file') }

  context 'clone repository' do
    When(:version_control) { Mist::VersionControl.new(variables, home_path) }
    Then { Dir.exists?(repository_path) }
  end

  context 'setup AWS dev tools' do
    When(:version_control) { Mist::VersionControl.new(variables, home_path) }
    Then { Dir.exists?(aws_dev_tools_path) }
  end

  context 'elastic beanstalk config' do
    When(:version_control) { Mist::VersionControl.new(variables, home_path) }
    Then { File.exists?(eb_config_file) }
    Then { File.read(eb_config_file).include? 'ApplicationName=application_name' }
    Then { File.read(eb_config_file).include? 'DevToolsEndpoint=dev_tools_endpoint' }
    Then { File.read(eb_config_file).include? 'EnvironmentName=environment-1' }
    Then { File.read(eb_config_file).include? 'Region=region' }
  end

  context 'elastic beanstalk aws credential file' do
    When(:version_control) { Mist::VersionControl.new(variables, home_path) }
    Then { File.exists?(aws_credential_file) }
    Then { File.read(aws_credential_file).include? 'AWSAccessKeyId=access_key_id' }
    Then { File.read(aws_credential_file).include? 'AWSSecretKey=secret_key' }
  end

  context 'deploy latest version' do
    Given(:kernel) { double('Kernel', system: nil) }
    Given(:version_control) { Mist::VersionControl.new(variables, home_path, kernel) }
    When { version_control.deploy_latest_version('test') }
    Then { expect(kernel).to have_received(:system).with('git pull') }
    Then { expect(kernel).to have_received(:system).with('git aws.push --environment test') }
  end
end
