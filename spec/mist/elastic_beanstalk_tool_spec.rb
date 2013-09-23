require 'spec_helper'

describe Mist::ElasticBeanstalkTool do
  Given(:home_path) { '/home/alex/mist' }
  Given(:cli_version) { 'AWS-ElasticBeanstalk-CLI-2.5.1' }
  Given(:cli_zip) { "#{cli_version}.zip" }
  Given(:cli_path) { "#{home_path}/#{cli_version}" }
  Given(:cli_file_path) { "#{home_path}/#{cli_zip}" }

  context 'set up' do
    Given(:cli_uri) { 'https://s3.amazonaws.com/elasticbeanstalk/cli/AWS-ElasticBeanstalk-CLI-2.5.1.zip' }
    Given(:system_command) { double('SystemCommand', run_command: nil) }
    Given(:file) { double('File', read: 'test') }
    Given { allow(file).to receive(:join).with(home_path, cli_version) { cli_path } }
    Given { allow(file).to receive(:join).with(home_path, cli_zip) { cli_file_path } }

    context 'setup AWS elastic beanstalk tool' do
      Given { allow(file).to receive(:exists?).with(cli_path) { false } }
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
      Given { allow(file).to receive(:exists?).with(cli_path) { true } }
      Given(:tool) {
        Mist::ElasticBeanstalkTool.new(home_path: home_path, file: file, system_command: system_command)
      }
      When(:result) { tool.setup }
      Then {
        expect(system_command).to_not have_received(:run_command)
      }
    end
  end

  context 'clean up' do
    context 'cleanup AWS elastic beanstalk tool' do
      Given (:glob_values) { [cli_version, cli_zip] }
      Given(:file) { double('File', read: 'test') }
      Given { allow(file).to receive(:join).with(home_path, cli_version) { cli_path } }
      Given(:file_utils) { double('FileUtils', rm_rf: nil) }
      Given { allow(file_utils).to receive(:rm_rf).with(glob_values) }
      Given(:dir) { double('Dir') }
      Given { allow(dir).to receive(:glob).with("#{cli_path}*") { glob_values } }
      Given { allow(dir).to receive(:exists?).with(cli_path) { true } }
      Given(:tool) {
        Mist::ElasticBeanstalkTool.new(home_path: home_path, file: file, file_utils: file_utils, dir: dir)
      }
      When(:result) { tool.cleanup }
      Then {
        expect(file_utils).to have_received(:rm_rf).with(glob_values)
      }
    end

    context 'AWS tool is already cleaned up' do
      Given (:glob_values) { [cli_version, cli_zip] }
      Given(:file_utils) { double('FileUtils', rm_rf: nil) }
      Given(:dir) { double('Dir') }
      Given { allow(dir).to receive(:exists?).with(cli_path) { false } }
      Given(:tool) {
        Mist::ElasticBeanstalkTool.new(home_path: home_path, file_utils: file_utils, dir: dir)
      }
      When(:result) { tool.cleanup }
      Then {
        expect(file_utils).to_not have_received(:rm_rf).with(glob_values)
      }
    end
  end
end
