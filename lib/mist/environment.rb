module Mist
  class Environment
    AWS_APP_ACCESS_KEY_ID = 'AWS_APP_ACCESS_KEY_ID'

    AWS_APP_SECRET_KEY = 'AWS_APP_SECRET_KEY'

    AWS_DNS_ACCESS_KEY_ID = 'AWS_DNS_ACCESS_KEY_ID'

    AWS_DNS_SECRET_KEY = 'AWS_DNS_SECRET_KEY'

    def initialize(name)
      raise error_message(AWS_APP_ACCESS_KEY_ID) unless app_access_key_id
      raise error_message(AWS_APP_SECRET_KEY) unless app_secret_key
      raise error_message(AWS_DNS_ACCESS_KEY_ID) unless dns_access_key_id
      raise error_message(AWS_DNS_SECRET_KEY) unless dns_secret_key

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
                  access_key_id: dns_access_key_id,
                  secret_key: dns_secret_key,
              }
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

    def find_environment(name)
      eb_config[:environments].select { |e| e[:name] == name }.first
    end

    def find_other_environment(name)
      eb_config[:environments].select { |e| e[:name] != name }.first
    end

    private

    def include_environment_information(name)
      #noinspection RubyResolve
      require "mist/environment/#{name.downcase}"
      #noinspection RubyResolve
      extend Mist::Environment.const_get(name.upcase.to_sym)
    end

    def error_message(variable)
      "Please specify the environment variable #{variable}"
    end

    def app_access_key_id
      ENV[AWS_APP_ACCESS_KEY_ID]
    end

    def app_secret_key
      ENV[AWS_APP_SECRET_KEY]
    end

    def dns_access_key_id
      ENV[AWS_DNS_ACCESS_KEY_ID]
    end

    def dns_secret_key
      ENV[AWS_DNS_SECRET_KEY]
    end
  end
end
