require 'time'
require 'fileutils'
require 'etc'
require 'aws-sdk'
require 'thor'
require 'new_relic_api'

require 'mist/version_control'
require 'mist/environment'
require 'mist/elastic_beanstalk'
require 'mist/website'
require 'mist/system_command'
require 'mist/dns'
require 'mist/newrelic'
require 'mist/deployment'
require 'mist/application'

module Mist
  extend self

  class << self
    attr_writer :logger
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
