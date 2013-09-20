$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
require 'rspec/given'

require 'mist'
require 'mist/spec'
require 'mist/fake_system_command'

Mist.logger = Logger.new('/dev/null')

CLI_LOCATION = File.expand_path(File.join(File.dirname(__FILE__), '..', 'AWS-ElasticBeanstalk-CLI-2.5.1'))
