module Mist
  class Environment
    attr_reader :name

    def initialize(name)
      raise error_message('AWS_ACCESS_KEY_ID') unless access_key_id
      raise error_message('AWS_SECRET_KEY') unless secret_key

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
              access_key_id: access_key_id,
              secret_key: secret_key,

              eb: {
                  application_name: 'PINCHme-US',
                  dev_tools_endpoint: 'git.elasticbeanstalk.us-east-1.amazonaws.com',
                  environments: send("#{name}_environments"),
                  region: 'us-east-1'
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

    def access_key_id
      ENV['AWS_ACCESS_KEY_ID']
    end

    def secret_key
      ENV['AWS_SECRET_KEY']
    end
  end
end
