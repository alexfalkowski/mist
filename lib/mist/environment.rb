module Mist
  class Environment
    AWS_APP_ACCESS_KEY_ID = 'AWS_APP_ACCESS_KEY_ID'

    AWS_APP_SECRET_KEY = 'AWS_APP_SECRET_KEY'

    AWS_DNS_ACCESS_KEY_ID = 'AWS_DNS_ACCESS_KEY_ID'

    AWS_DNS_SECRET_KEY = 'AWS_DNS_SECRET_KEY'

    NEWRELIC_API_KEY = 'NEWRELIC_API_KEY'

    def initialize(name)
      @app_access_key_id = Mist::EnvironmentVariable.new(AWS_APP_ACCESS_KEY_ID).value
      @app_secret_key = Mist::EnvironmentVariable.new(AWS_APP_SECRET_KEY).value
      @dns_access_key_id = Mist::EnvironmentVariable.new(AWS_DNS_ACCESS_KEY_ID).value
      @dns_secret_key = Mist::EnvironmentVariable.new(AWS_DNS_SECRET_KEY).value
      @newrelic_api_key = Mist::EnvironmentVariable.new(NEWRELIC_API_KEY).value

      include_environment_information name
    end

    def variables
      @variables ||= {
        git: {
          repository_name: 'PINCHme',
          repository_uri: 'git@github.com:mojotech/PinchMe.git',
          local_path: '/tmp'
        },
        aws: {
          eb: {
            access_key_id: app_access_key_id,
            secret_key: app_secret_key,
            application_name: 'PINCHme-US',
            dev_tools_endpoint: 'git.elasticbeanstalk.us-east-1.amazonaws.com',
            environments: environments,
            region: 'us-east-1'
          },
          dns: {
            hosted_zone: 'pinchme.com.',
            domain: domain,
            endpoint: endpoint,
            access_key_id: dns_access_key_id,
            secret_key: dns_secret_key,
          }
        },
        newrelic: {
          api_key: newrelic_api_key,
          application_name: application_name
        }
      }
    end

    def eb_config
      variables[:aws][:eb]
    end

    def dns_config
      variables[:aws][:dns]
    end

    def git_config
      variables[:git]
    end

    def newrelic_config
      variables[:newrelic]
    end

    def find_environment(name)
      eb_config[:environments].select { |e| e[:name] == name }.first
    end

    def find_next_environment(name)
      eb_config[:environments].select { |e| e[:name] != name }.first
    end

    private

    attr_reader :app_access_key_id, :app_secret_key, :dns_access_key_id, :dns_secret_key, :newrelic_api_key

    def include_environment_information(name)
      #noinspection RubyResolve
      require "mist/environment/#{name.downcase}"
      #noinspection RubyResolve
      extend Mist::Environment.const_get(name.upcase.to_sym)
    end
  end
end
