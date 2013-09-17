require 'time'
require 'fileutils'
require 'aws-sdk'

require 'mist/version_control'
require 'mist/environment'
require 'mist/elastic_beanstalk'
require 'mist/website'
require 'mist/system_command'
require 'mist/deployment'

module Mist
  extend self

  class << self
    attr_writer :logger
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
