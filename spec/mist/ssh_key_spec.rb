require 'spec_helper'

describe Mist::SshKey do
  context 'key not generated' do
    Given(:home_path) { '/home/alex' }
    Given(:file) {
      double('File', exists?: false, join: 'path', read: 'test')
    }
    Given(:email) { 'test@test.com' }
    Given(:system_command) { double('SystemCommand', run_command: nil) }
    Given(:ssh_key) {
      Mist::SshKey.new(home_path: home_path, file: file, email: email, system_command: system_command)
    }
    When(:value) { ssh_key.value }
    Then {
      expect(file).to have_received(:join).with('/home/alex', '/.ssh/id_rsa.pub')
    }
    Then {
      expect(file).to have_received(:read).with('path')
    }
    Then {
      expect(system_command).to have_received(:run_command).with('ssh-keygen',
                                                                 '-q',
                                                                 '-t rsa',
                                                                 '-C test@test.com',
                                                                 "-N ''",
                                                                 '-f path')
    }
    Then { value == 'test' }
  end

  context 'key generated' do
    Given(:home_path) { '/home/alex' }
    Given(:file) {
      double('File', exists?: true, join: 'path', read: 'test')
    }
    Given(:email) { 'test@test.com' }
    Given(:system_command) { double('SystemCommand', run_command: nil) }
    Given(:ssh_key) {
      Mist::SshKey.new(home_path: home_path, file: file, email: email, system_command: system_command)
    }
    When(:value) { ssh_key.value }
    Then {
      expect(file).to have_received(:join).with('/home/alex', '/.ssh/id_rsa.pub')
    }
    Then {
      expect(file).to have_received(:read).with('path')
    }
    Then { expect(system_command).to_not have_received(:run_command) }
    Then { value == 'test' }
  end
end
