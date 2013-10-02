require 'spec_helper'

describe Mist::VersionControl do
  let(:environment) { Spec.environment }
  let (:repository_uri) { environment.git_config[:repository_uri] }

  let(:repository_path) {
    File.join(environment.git_config[:local_path], environment.git_config[:repository_name])
  }

  Given(:system_command) { double('SystemCommand', run_command: nil) }

  context 'clone repository' do
    When(:version_control) {
      Mist::VersionControl.new(environment: environment,
                               system_command: system_command)
    }
    Then {
      expect(system_command).to have_received(:run_command).with('git clone',
                                                                 repository_uri,
                                                                 repository_path,
                                                                 '-q')
    }
  end

  context 'deploy latest version' do
    Given(:version_control) {
      Mist::VersionControl.new(environment: environment,
                               system_command: system_command)
    }
    When { version_control.push_latest_version('test') }
    Then { expect(system_command).to have_received(:run_command).with('git checkout', 'master', '-q') }
    Then { expect(system_command).to have_received(:run_command).with('git pull', '-q') }
    Then {
      expect(system_command).to have_received(:run_command).with('git aws.push',
                                                                 '--environment test',
                                                                 '> /dev/null 2>&1')
    }
  end

  context 'checkout specific version' do
    Given(:version_control) {
      Mist::VersionControl.new(environment: environment,
                               system_command: system_command)
    }
    When { version_control.push_version('test', 'test') }
    Then { expect(system_command).to have_received(:run_command).with('git checkout', 'master', '-q') }
    Then { expect(system_command).to have_received(:run_command).with('git pull', '-q') }
    Then { expect(system_command).to have_received(:run_command).with('git checkout', 'test', '-q')}
    Then {
      expect(system_command).to have_received(:run_command).with('git aws.push',
                                                                 '--environment test',
                                                                 '> /dev/null 2>&1')
    }
  end
end
