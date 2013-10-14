module Mist
  class Environment
    AWS_APP_ACCESS_KEY_ID = 'AWS_APP_ACCESS_KEY_ID'

    AWS_APP_SECRET_KEY = 'AWS_APP_SECRET_KEY'

    AWS_DNS_ACCESS_KEY_ID = 'AWS_DNS_ACCESS_KEY_ID'

    AWS_DNS_SECRET_KEY = 'AWS_DNS_SECRET_KEY'

    NEWRELIC_API_KEY = 'NEWRELIC_API_KEY'

    def initialize(options = {})
      @app_access_key_id = Mist::EnvironmentVariable.new(AWS_APP_ACCESS_KEY_ID).value
      @app_secret_key = Mist::EnvironmentVariable.new(AWS_APP_SECRET_KEY).value
      @dns_access_key_id = Mist::EnvironmentVariable.new(AWS_DNS_ACCESS_KEY_ID).value
      @dns_secret_key = Mist::EnvironmentVariable.new(AWS_DNS_SECRET_KEY).value
      @newrelic_api_key = Mist::EnvironmentVariable.new(NEWRELIC_API_KEY).value
      @name = options[:name]
      @path = options.fetch(:path, 'config.yml')
    end

    def variables
      @variables ||= {
        git: {
          repository_name: git['repository_name'],
          repository_uri: git['repository_uri'],
          local_path: git['local_path']
        },
        basic_auth: symbolize_keys(basic_auth),
        aws: {
          eb: {
            access_key_id: app_access_key_id,
            secret_key: app_secret_key,
            application_name: aws['application_name'],
            dev_tools_endpoint: aws['dev_tools_endpoint'],
            environments: symbolize_keys(stack['environments']),
            region: aws['region']
          },
          dns: {
            hosted_zone: aws['hosted_zone'],
            domain: stack['domain'],
            endpoint: stack['endpoint'],
            access_key_id: dns_access_key_id,
            secret_key: dns_secret_key,
          }
        },
        newrelic: {
          api_key: newrelic_api_key,
          application_name: stack['newrelic_application_name']
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

    def basic_auth_config
      variables[:basic_auth]
    end

    def find_environment(name)
      eb_config[:environments].select { |e| e[:name] == name }.first
    end

    def find_next_environment(name)
      eb_config[:environments].select { |e| e[:name] != name }.first
    end

    private

    attr_reader :app_access_key_id, :app_secret_key, :dns_access_key_id, :dns_secret_key, :newrelic_api_key,
                :name, :path

    def config
      @config ||= YAML.load_file(path)
    end

    def stack
      aws['stacks'][name].tap { |s| raise "The stack '#{name}' does not exist!" unless s }
    end

    def basic_auth
      stack['basic_auth']
    end

    def aws
      config['aws']
    end

    def git
      config['git']
    end

    def symbolize_keys(hash)
      case hash
      when Hash
        Hash[hash.map { |k, v| [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize_keys(v)] }]
      when Enumerable
        hash.map { |v| symbolize_keys(v) }
      else
        hash
      end
    end
  end
end
