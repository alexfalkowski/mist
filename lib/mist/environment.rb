module Mist
  class Environment
    AWS_APP_ACCESS_KEY_ID = 'AWS_APP_ACCESS_KEY_ID'

    AWS_APP_SECRET_KEY = 'AWS_APP_SECRET_KEY'

    AWS_DNS_ACCESS_KEY_ID = 'AWS_DNS_ACCESS_KEY_ID'

    AWS_DNS_SECRET_KEY = 'AWS_DNS_SECRET_KEY'

    attr_reader :name

    def initialize(name)
      raise error_message(AWS_APP_ACCESS_KEY_ID) unless app_access_key_id
      raise error_message(AWS_APP_SECRET_KEY) unless app_secret_key
      raise error_message(AWS_DNS_ACCESS_KEY_ID) unless dns_access_key_id
      raise error_message(AWS_DNS_SECRET_KEY) unless dns_secret_key

      @name = name.downcase
    end

    def variables
      {
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
                  environments: send("#{name}_environments"),
                  region: 'us-east-1'
              },
              dns: {
                  access_key_id: dns_access_key_id,
                  secret_key: dns_secret_key,
              }
          }
      }
    end

    private

    def qa_environments
      [
          {
              name: 'PINCHme-US-QA-A',
              uri: 'http://pinchme-us-qa-a-jn9wvp4tew.elasticbeanstalk.com/'
          },
          {
              name: 'PINCHme-US-QA-B',
              uri: 'http://pinchme-us-qa-b-ghruzpydi6.elasticbeanstalk.com/'
          },
      ]
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
