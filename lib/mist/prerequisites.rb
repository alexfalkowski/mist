module Mist
  GITHUB_ACCESS_TOKEN = 'GITHUB_ACCESS_TOKEN'

  class Prerequisites
    def initialize(options = {})
      @access_token = Mist::EnvironmentVariable.new(GITHUB_ACCESS_TOKEN).value
      @email = options[:email]
      @github = options.fetch(:github) { Mist::GitHub.new(access_token: access_token, email: email) }
      @eb_tool = options.fetch(:eb_tool) { Mist::ElasticBeanstalkTool.new }
    end

    def setup
      github.register_deployment_key
      eb_tool.setup
    end

    def cleanup
      github.unregister_deployment_key
      eb_tool.cleanup
    end

    private

    attr_reader :access_token, :email, :github, :eb_tool
  end
end
