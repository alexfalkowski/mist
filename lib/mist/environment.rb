module Mist
  class Environment
    attr_reader :name

    def initialize(name)
      @name = name

      raise error_message('AWS_ACCESS_KEY_ID') unless access_key_id
      raise error_message('AWS_SECRET_KEY') unless secret_key
    end

    def variables
      {
          git: {
              repository_name: 'PINCHme',
              repository_uri: 'git@github.com:mojotech/PinchMe.git',
              local_path: '/tmp'
          },
          aws: {
              access_key_id: access_key_id,
              secret_key: secret_key,

              eb: {
                  application_name: 'PINCHme-US',
                  dev_tools_endpoint: 'git.elasticbeanstalk.us-east-1.amazonaws.com',
                  environments: [
                      {name: 'PINCHme-US-QA-A'},
                      {name: 'PINCHme-US-QA-B'},
                  ],
                  region: 'us-east-1'
              }
          }
      }
    end

    private

    def error_message(variable)
      "Please specify the environment variable #{variable}"
    end

    def access_key_id
      ENV['AWS_ACCESS_KEY_ID']
    end

    def secret_key
      ENV['AWS_SECRET_KEY']
    end
  end
end
