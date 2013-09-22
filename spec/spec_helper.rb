$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
require 'rspec/given'

require 'mist'
require 'mist/spec'
require 'mist/spec_system_command'

Mist.logger = Logger.new('/dev/null')
