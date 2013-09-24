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
      unless find_key_by_title
        last_index = ssh_key.value.rindex(' ') - 1
        key_value = ssh_key.value[0..last_index]
        unless find_key_by_value(key_value)
          client.add_key(DEPLOYMENT_GITHUB_KEY, ssh_key.value)
        end
      end
    end

    def unregister_deployment_key
      client.remove_key(find_key_by_title[:id]) if find_key_by_title
    end

    private

    attr_reader :access_token, :email, :client, :ssh_key

    def find_key_by_title
      @key_by_title ||= client.keys.select { |key| key[:title] == DEPLOYMENT_GITHUB_KEY }.first
    end

    def find_key_by_value(value)
      @key_by_title ||= client.keys.select { |key| key[:key] == value }.first
    end
  end
end
