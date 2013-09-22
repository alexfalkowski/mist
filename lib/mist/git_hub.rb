module Mist
  class GitHub
    DEPLOYMENT_GITHUB_KEY = 'PINCHme US Deployment'

    def initialize(options = {})
      @access_token = options[:access_token]
      @email = options[:email]
      @client = options.fetch(:client) { Octokit::Client.new(access_token: access_token) }
      @ssh_key = options.fetch(:ssh_key) { Mist::SshKey.new(email: email) }
    end

    def register_deployment_key
      key = client.keys.select { |key| key[:title] == DEPLOYMENT_GITHUB_KEY }.first

      client.add_key(DEPLOYMENT_GITHUB_KEY, ssh_key.value) unless key
    end

    private

    attr_reader :access_token, :email, :client, :ssh_key
  end
end
