$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
require 'rspec/given'

require 'mist'
require 'mist/spec'

Mist.logger = Logger.new('/dev/null')
