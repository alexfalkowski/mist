require 'time'
require 'fileutils'
require 'etc'
require 'aws-sdk'
require 'thor'
require 'new_relic_api'
require 'octokit'

require 'mist/version_control'
require 'mist/environment'
require 'mist/environment_variable'
require 'mist/elastic_beanstalk'
require 'mist/website'
require 'mist/system_command'
require 'mist/dns'
require 'mist/newrelic'
require 'mist/git_hub'
require 'mist/ssh_key'
require 'mist/elastic_beanstalk_tool'
require 'mist/prerequisites'
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
