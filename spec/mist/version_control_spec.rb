require 'spec_helper'

describe Mist::VersionControl do
  let(:environment) { Spec.environment }

  let(:repository_path) {
    File.join(environment.git_config[:local_path], environment.git_config[:repository_name])
  }

  context 'clone repository' do
    Given(:system_command) { SpecSystemCommand.new }
    When(:version_control) {
      Mist::VersionControl.new(environment: environment,
                               system_command: system_command)
    }
    Then { Dir.exists?(repository_path) }
  end

  context 'deploy latest version' do
    Given(:system_command) { double('SystemCommand', run_command: nil) }
    Given(:version_control) {
      Mist::VersionControl.new(environment: environment,
                               system_command: system_command)
    }
    When { version_control.push_latest_version('test') }
    Then { expect(system_command).to have_received(:run_command).with('git pull', '-q') }
    Then {
      expect(system_command).to have_received(:run_command).with('git aws.push',
                                                                 '--environment test',
                                                                 '> /dev/null 2>&1')
    }
  end
end
