require 'spec_helper'

describe Mist::ElasticBeanstalkTool do
  Given(:home_path) { '/home/alex/mist' }
  Given(:cli_version) { 'AWS-ElasticBeanstalk-CLI-2.5.1' }
  Given(:cli_zip) { "#{cli_version}.zip" }
  Given(:cli_path) { "#{home_path}/#{cli_version}" }
  Given(:cli_file_path) { "#{home_path}/#{cli_zip}" }
  Given(:cli_uri) { 'https://s3.amazonaws.com/elasticbeanstalk/cli/AWS-ElasticBeanstalk-CLI-2.5.1.zip' }
  Given(:system_command) { double('SystemCommand', run_command: nil) }
  Given(:file) { double('File', read: 'test') }
  Given { allow(file).to receive(:join).with(home_path, cli_version) { cli_path }}
  Given { allow(file).to receive(:join).with(home_path, cli_zip) { cli_file_path }}

  context 'prepare AWS elastic beanstalk tool' do
    Given(:file) {
      double('File', exists?: false, read: 'test')
    }
    Given { allow(file).to receive(:exists?).with(cli_path) { false }}
    Given(:tool) {
      Mist::ElasticBeanstalkTool.new(home_path: home_path, file: file, system_command: system_command)
    }
    When(:result) { tool.setup }
    Then {
      expect(system_command).to have_received(:run_command).with('curl',
                                                                 '-s',
                                                                 "-o #{cli_file_path}",
                                                                 cli_uri)
    }
    Then {
      expect(system_command).to have_received(:run_command).with('unzip',
                                                                 '-o',
                                                                 '-q',
                                                                 "-d #{home_path}",
                                                                 cli_file_path)
    }
  end

  context 'AWS tool is already prepared' do
    Given { allow(file).to receive(:exists?).with(cli_path) { true }}
    Given(:tool) {
      Mist::ElasticBeanstalkTool.new(home_path: home_path, file: file, system_command: system_command)
    }
    When(:result) { tool.setup }
    Then {
      expect(system_command).to_not have_received(:run_command)
    }
  end
end
